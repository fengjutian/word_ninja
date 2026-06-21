package auth

import (
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/word-ninja/server/internal/vocabulary"
	"github.com/word-ninja/server/pkg/jwt"
	"gorm.io/gorm"
)

type Handler struct {
	DB        *gorm.DB
	JWTSecret string
}

// Register 用户注册
func (h *Handler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := Register(h.DB, req)
	if err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "邮箱已被注册"})
		return
	}
	token, expiresAt, err := jwt.GenerateToken(h.JWTSecret, user.ID, user.Email)
	if err != nil {
		slog.Error("generate token failed", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败"})
		return
	}
	c.JSON(http.StatusCreated, LoginResponse{
		Token:     token,
		ExpiresAt: expiresAt.Format("2006-01-02T15:04:05Z"),
		User:      *user,
	})
}

// Login 用户登录
func (h *Handler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := Login(h.DB, req)
	if err != nil {
		if err == ErrWrongPassword {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "邮箱或密码错误"})
		} else {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "邮箱或密码错误"})
		}
		return
	}
	token, expiresAt, err := jwt.GenerateToken(h.JWTSecret, user.ID, user.Email)
	if err != nil {
		slog.Error("generate token failed", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败"})
		return
	}
	c.JSON(http.StatusOK, LoginResponse{
		Token:     token,
		ExpiresAt: expiresAt.Format("2006-01-02T15:04:05Z"),
		User:      *user,
	})
}

// RefreshToken 刷新令牌
func (h *Handler) RefreshToken(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "缺少认证信息"})
		return
	}
	tokenStr := authHeader
	if len(authHeader) > 7 && authHeader[:7] == "Bearer " {
		tokenStr = authHeader[7:]
	}
	claims, err := jwt.ParseToken(h.JWTSecret, tokenStr)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "token无效或已过期"})
		return
	}
	newToken, expiresAt, err := jwt.GenerateToken(h.JWTSecret, claims.UserID, claims.Email)
	if err != nil {
		slog.Error("refresh token failed", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "刷新令牌失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"token":      newToken,
		"expires_at": expiresAt.Format("2006-01-02T15:04:05Z"),
	})
}

// Me 获取当前用户信息
func (h *Handler) Me(c *gin.Context) {
	userID := c.GetString("user_id")
	user, err := GetUserByID(h.DB, userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": user})
}

// UpdateMe 更新当前用户信息
func (h *Handler) UpdateMe(c *gin.Context) {
	userID := c.GetString("user_id")
	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := UpdateUser(h.DB, userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新用户失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": user})
}

// Stats 获取用户统计信息
func (h *Handler) Stats(c *gin.Context) {
	userID := c.GetString("user_id")
	stats := vocabulary.GetUserStats(h.DB, userID)
	c.JSON(http.StatusOK, gin.H{"data": stats})
}

// Achievements 获取用户成就列表
func (h *Handler) Achievements(c *gin.Context) {
	userID := c.GetString("user_id")
	achievements, err := vocabulary.GetUserAchievements(h.DB, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取成就失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": achievements})
}
