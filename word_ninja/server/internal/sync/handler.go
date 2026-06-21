package sync

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/word-ninja/server/internal/vocabulary"
	"gorm.io/gorm"
)

type Handler struct {
	DB *gorm.DB
}

type SyncRequest struct {
	Words []vocabulary.CreateWordRequest `json:"words"`
}

type SyncResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

// Sync 数据同步（客户端 → 服务端）
func (h *Handler) Sync(c *gin.Context) {
	userID := c.GetString("user_id")
	var req SyncRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	synced := 0
	for _, w := range req.Words {
		_, err := vocabulary.CreateWord(h.DB, userID, w)
		if err != nil {
			continue // 跳过已存在的
		}
		synced++
	}

	c.JSON(http.StatusOK, SyncResponse{
		Success: true,
		Message: "同步成功",
	})
}
