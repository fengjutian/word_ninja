package auth

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	Email     string    `gorm:"uniqueIndex;not null;size:255" json:"email"`
	Nickname  string    `gorm:"not null;size:100" json:"nickname"`
	Password  string    `gorm:"not null;size:255" json:"-"` // bcrypt hash, 不在JSON中暴露
	Avatar    string    `gorm:"size:500" json:"avatar"`
	Level     int       `gorm:"default:1" json:"level"`
	Exp       int       `gorm:"default:0" json:"exp"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// RegisterRequest 注册请求
type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Nickname string `json:"nickname" binding:"required,min=1,max=100"`
	Password string `json:"password" binding:"required,min=6"`
}

// LoginRequest 登录请求
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Token     string `json:"token"`
	ExpiresAt string `json:"expires_at"`
	User      User   `json:"user"`
}

// Register 注册用户
func Register(db *gorm.DB, req RegisterRequest) (*User, error) {
	hash, err := hashPassword(req.Password)
	if err != nil {
		return nil, err
	}
	user := User{
		Email:    req.Email,
		Nickname: req.Nickname,
		Password: hash,
		Level:    1,
		Exp:      0,
	}
	if err := db.Create(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

// Login 登录校验
func Login(db *gorm.DB, req LoginRequest) (*User, error) {
	var user User
	if err := db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return nil, err
	}
	if !checkPassword(user.Password, req.Password) {
		return nil, gorm.ErrRecordNotFound
	}
	return &user, nil
}

// GetUserByID 根据ID获取用户
func GetUserByID(db *gorm.DB, id string) (*User, error) {
	var user User
	if err := db.Where("id = ?", id).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}
