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
