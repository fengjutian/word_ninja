package ai

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	APIKey     string
	BaseURL    string
	HTTPClient *http.Client
}

type chatRequest struct {
	Message string              `json:"message" binding:"required"`
	History []map[string]string `json:"history"`
}

type explainRequest struct {
	Word string `json:"word" binding:"required"`
}

type planRequest struct {
	Goal      string `json:"goal" binding:"required"`
	DayCount  int    `json:"day_count"`
	Level     int    `json:"level"`
}

type correctRequest struct {
	Text string `json:"text" binding:"required"`
}

type openaiMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type openaiRequest struct {
	Model       string          `json:"model"`
	Messages    []openaiMessage `json:"messages"`
	Temperature float64         `json:"temperature"`
	MaxTokens   int             `json:"max_tokens"`
	Stream      bool            `json:"stream"`
}

type openaiChoice struct {
	Delta struct {
		Content string `json:"content"`
	} `json:"delta"`
	FinishReason *string `json:"finish_reason"`
}

type openaiChunk struct {
	Choices []openaiChoice `json:"choices"`
}

type openaiNonStreamResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

// callOpenAI 调用 OpenAI API（非流式）
func (h *Handler) callOpenAI(ctx *gin.Context, systemPrompt, userMessage string) (string, error) {
	messages := []openaiMessage{
		{Role: "system", Content: systemPrompt},
		{Role: "user", Content: userMessage},
	}
	body := openaiRequest{
		Model:       "gpt-4o-mini",
		Messages:    messages,
		Temperature: 0.7,
		MaxTokens:   1000,
		Stream:      false,
	}
	jsonBody, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}
	httpReq, err := http.NewRequestWithContext(ctx.Request.Context(), "POST",
		fmt.Sprintf("%s/chat/completions", strings.TrimSuffix(h.BaseURL, "/")),
		bytes.NewReader(jsonBody))
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+h.APIKey)

	resp, err := h.HTTPClient.Do(httpReq)
	if err != nil {
		return "", fmt.Errorf("ai service unavailable: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("read response: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("ai error: %s", string(respBody))
	}
	var result openaiNonStreamResponse
	if err := json.Unmarshal(respBody, &result); err != nil {
		return "", fmt.Errorf("parse response: %w", err)
	}
	if len(result.Choices) == 0 {
		return "", fmt.Errorf("no response from AI")
	}
	return result.Choices[0].Message.Content, nil
}

// Chat AI 聊天（支持流式 SSE）
func (h *Handler) Chat(c *gin.Context) {
	var req chatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	messages := []openaiMessage{
		{Role: "system", Content: "你是 Word Ninja 的 AI 导师 Sensei Shell，帮助用户学习英语。用中文回复。"},
	}
	for _, m := range req.History {
		role := m["role"]
		if role != "user" && role != "assistant" {
			role = "user"
		}
		messages = append(messages, openaiMessage{Role: role, Content: m["content"]})
	}
	messages = append(messages, openaiMessage{Role: "user", Content: req.Message})

	body := openaiRequest{
		Model:       "gpt-4o-mini",
		Messages:    messages,
		Temperature: 0.7,
		MaxTokens:   1000,
		Stream:      true,
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		slog.Error("marshal chat request failed", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "请求序列化失败"})
		return
	}
	httpReq, err := http.NewRequestWithContext(c.Request.Context(), "POST",
		fmt.Sprintf("%s/chat/completions", strings.TrimSuffix(h.BaseURL, "/")),
		bytes.NewReader(jsonBody))
	if err != nil {
		slog.Error("create chat request failed", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建请求失败"})
		return
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+h.APIKey)

	resp, err := h.HTTPClient.Do(httpReq)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "AI 服务不可用"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		respBody, err := io.ReadAll(resp.Body)
		errMsg := "AI 请求失败"
		if err == nil {
			errMsg = fmt.Sprintf("AI 错误: %s", string(respBody))
		}
		c.JSON(http.StatusBadGateway, gin.H{"error": errMsg})
		return
	}

	// SSE 流式转发
	c.Header("Content-Type", "text/event-stream")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")
	c.Status(http.StatusOK)

	reader := bufio.NewReader(resp.Body)
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			break
		}
		line = strings.TrimSpace(line)
		if !strings.HasPrefix(line, "data: ") {
			continue
		}
		data := strings.TrimPrefix(line, "data: ")
		if data == "[DONE]" {
			fmt.Fprintf(c.Writer, "data: [DONE]\n\n")
			c.Writer.Flush()
			break
		}
		var chunk openaiChunk
		if err := json.Unmarshal([]byte(data), &chunk); err != nil {
			continue
		}
		if len(chunk.Choices) > 0 && chunk.Choices[0].Delta.Content != "" {
			fmt.Fprintf(c.Writer, "data: %s\n\n", data)
			c.Writer.Flush()
		}
	}
}

// Explain AI 单词解释
func (h *Handler) Explain(c *gin.Context) {
	var req explainRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	result, err := h.callOpenAI(c,
		"你是 Word Ninja 的 AI 导师。请用中文详细解释以下英语单词，包括：词性、中文释义、词根词缀分析、常见搭配、例句。",
		fmt.Sprintf("请解释单词: %s", req.Word),
	)
	if err != nil {
		slog.Error("ai explain failed", "error", err)
		c.JSON(http.StatusBadGateway, gin.H{"error": "AI 解释失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": gin.H{"word": req.Word, "explanation": result}})
}

// Plan AI 学习计划生成
func (h *Handler) Plan(c *gin.Context) {
	var req planRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.DayCount <= 0 {
		req.DayCount = 7
	}
	prompt := fmt.Sprintf("用户的学习目标是: %s。用户当前等级: %d。请生成一个 %d 天的英语学习计划，每天列出具体的学习任务。",
		req.Goal, req.Level, req.DayCount)
	result, err := h.callOpenAI(c,
		"你是 Word Ninja 的 AI 导师。请根据用户的学习目标和等级，生成一份结构化的英语学习计划。用中文回复。",
		prompt,
	)
	if err != nil {
		slog.Error("ai plan failed", "error", err)
		c.JSON(http.StatusBadGateway, gin.H{"error": "AI 计划生成失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": gin.H{"plan": result}})
}

// Correct AI 写作批改
func (h *Handler) Correct(c *gin.Context) {
	var req correctRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	result, err := h.callOpenAI(c,
		"你是 Word Ninja 的 AI 写作导师。请批改以下英文文本，指出语法错误、用词不当、并提供改进建议。用中文回复。",
		fmt.Sprintf("请批改以下文本，指出错误并给出修改建议:\n\n%s", req.Text),
	)
	if err != nil {
		slog.Error("ai correct failed", "error", err)
		c.JSON(http.StatusBadGateway, gin.H{"error": "AI 批改失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": gin.H{"original": req.Text, "correction": result}})
}
