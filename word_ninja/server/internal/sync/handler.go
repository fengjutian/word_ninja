package sync

import (
	"log/slog"
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
	Success   bool     `json:"success"`
	Message   string   `json:"message"`
	Synced    int      `json:"synced"`
	Total     int      `json:"total"`
	FailedIDs []string `json:"failed_ids,omitempty"`
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
	failedIDs := make([]string, 0)
	for _, w := range req.Words {
		_, err := vocabulary.CreateWord(h.DB, userID, w)
		if err != nil {
			slog.Warn("sync word failed", "word", w.Word, "error", err)
			failedIDs = append(failedIDs, w.Word)
			continue
		}
		synced++
	}

	c.JSON(http.StatusOK, SyncResponse{
		Success:   true,
		Message:   "同步完成",
		Synced:    synced,
		Total:     len(req.Words),
		FailedIDs: failedIDs,
	})
}
