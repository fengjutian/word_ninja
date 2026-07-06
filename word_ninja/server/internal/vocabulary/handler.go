package vocabulary

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Handler struct {
	DB *gorm.DB
}

// List 获取单词列表
func (h *Handler) List(c *gin.Context) {
	userID := c.GetString("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}

	result, err := ListWords(h.DB, userID, page, size)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取单词列表失败"})
		return
	}
	c.JSON(http.StatusOK, result)
}

// Get 获取单个单词
func (h *Handler) Get(c *gin.Context) {
	userID := c.GetString("user_id")
	wordID := c.Param("id")
	word, err := GetWordByID(h.DB, userID, wordID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "单词不存在"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": word})
}

// Create 创建单词
func (h *Handler) Create(c *gin.Context) {
	userID := c.GetString("user_id")
	var req CreateWordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	word, err := CreateWord(h.DB, userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建单词失败"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": word})
}

// Update 更新单词
func (h *Handler) Update(c *gin.Context) {
	userID := c.GetString("user_id")
	wordID := c.Param("id")
	var req UpdateWordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	word, err := UpdateWord(h.DB, userID, wordID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新单词失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": word})
}

// Delete 删除单词
func (h *Handler) Delete(c *gin.Context) {
	userID := c.GetString("user_id")
	wordID := c.Param("id")
	if err := DeleteWord(h.DB, userID, wordID); err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "单词不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "删除单词失败"})
		}
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

// Review 提交复习记录
func (h *Handler) Review(c *gin.Context) {
	userID := c.GetString("user_id")
	var req CreateReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	review, err := CreateReview(h.DB, userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "提交复习失败"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": review})
}

// DueReviews 获取到期复习单词
func (h *Handler) DueReviews(c *gin.Context) {
	userID := c.GetString("user_id")
	words, err := GetDueReviews(h.DB, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取复习列表失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": words})
}

// Graph 获取单词关系图谱
func (h *Handler) Graph(c *gin.Context) {
	userID := c.GetString("user_id")
	wordID := c.Param("id")
	result, err := GraphWords(h.DB, userID, wordID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "单词不存在"})
		return
	}
	c.JSON(http.StatusOK, result)
}

// Leaderboard 获取排行榜
func (h *Handler) Leaderboard(c *gin.Context) {
	limit := 20
	if l, err := strconv.Atoi(c.DefaultQuery("limit", "20")); err == nil && l > 0 && l <= 100 {
		limit = l
	}
	entries, err := GetLeaderboard(h.DB, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取排行榜失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": entries})
}

// ─── Study Plan ───

// ListPlans 获取学习计划列表
func (h *Handler) ListPlans(c *gin.Context) {
	userID := c.GetString("user_id")
	var plans []StudyPlan
	h.DB.Where("user_id = ?", userID).Order("created_at DESC").Find(&plans)
	c.JSON(http.StatusOK, gin.H{"data": plans})
}

// GetPlan 获取单个计划
func (h *Handler) GetPlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")
	var plan StudyPlan
	if err := h.DB.Where("id = ? AND user_id = ?", planID, userID).First(&plan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "计划不存在"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": plan})
}

// CreatePlan 创建学习计划
func (h *Handler) CreatePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	var req struct {
		Goal     string `json:"goal" binding:"required"`
		DayCount int    `json:"day_count"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.DayCount <= 0 {
		req.DayCount = 7
	}
	plan := StudyPlan{
		UserID:   userID,
		Goal:     req.Goal,
		DayCount: req.DayCount,
		IsActive: true,
	}
	if err := h.DB.Create(&plan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建计划失败"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": plan})
}

// UpdatePlan 更新学习计划进度
func (h *Handler) UpdatePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")
	var req struct {
		CurrentDay *int  `json:"current_day"`
		IsActive   *bool `json:"is_active"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	updates := map[string]interface{}{}
	if req.CurrentDay != nil {
		updates["current_day"] = *req.CurrentDay
	}
	if req.IsActive != nil {
		updates["is_active"] = *req.IsActive
	}
	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无更新内容"})
		return
	}
	if err := h.DB.Model(&StudyPlan{}).
		Where("id = ? AND user_id = ?", planID, userID).
		Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新计划失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "更新成功"})
}

// DeletePlan 删除学习计划
func (h *Handler) DeletePlan(c *gin.Context) {
	userID := c.GetString("user_id")
	planID := c.Param("id")
	result := h.DB.Where("id = ? AND user_id = ?", planID, userID).Delete(&StudyPlan{})
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "计划不存在"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}
