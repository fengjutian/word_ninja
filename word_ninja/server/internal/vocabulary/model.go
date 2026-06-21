package vocabulary

import (
	"time"

	"gorm.io/gorm"
)

// Word 单词模型
type Word struct {
	ID         string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID     string    `gorm:"not null;index" json:"user_id"`
	Word       string    `gorm:"not null;size:255" json:"word"`
	Meaning    string    `gorm:"type:text;not null" json:"meaning"`
	Phonetic   string    `gorm:"size:100" json:"phonetic"`
	Example    string    `gorm:"type:text" json:"example"`
	Difficulty int       `gorm:"default:1" json:"difficulty"`
	Mastery    int       `gorm:"default:0" json:"mastery"`
	Source     string    `gorm:"size:20;default:manual" json:"source"`
	Tags       string    `gorm:"type:text" json:"tags"` // JSON array stored as text
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// Review 复习记录
type Review struct {
	ID         string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	WordID     string    `gorm:"not null;index" json:"word_id"`
	UserID     string    `gorm:"not null;index" json:"user_id"`
	ReviewTime time.Time `gorm:"not null" json:"review_time"`
	Score      int       `gorm:"not null" json:"score"` // 1-5
	CreatedAt  time.Time `json:"created_at"`
}

// Achievement 成就模型
type Achievement struct {
	ID         string     `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID     string     `gorm:"not null;index" json:"user_id"`
	Type       string     `gorm:"not null;size:50" json:"type"`
	Title      string     `gorm:"not null;size:200" json:"title"`
	Progress   int        `gorm:"default:0" json:"progress"`
	Target     int        `gorm:"not null" json:"target"`
	IsUnlocked bool       `gorm:"default:false" json:"is_unlocked"`
	UnlockedAt *time.Time `json:"unlocked_at"`
	CreatedAt  time.Time  `json:"created_at"`
}

// StudyPlan 学习计划模型
type StudyPlan struct {
	ID         string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID     string    `gorm:"not null;index" json:"user_id"`
	Goal       string    `gorm:"type:text;not null" json:"goal"`
	DayCount   int       `gorm:"default:7" json:"day_count"`
	CurrentDay int       `gorm:"default:1" json:"current_day"`
	IsActive   bool      `gorm:"default:true" json:"is_active"`
	CreatedAt  time.Time `json:"created_at"`
}

// ChatMessage 聊天消息模型
type ChatMessage struct {
	ID        string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID    string    `gorm:"not null;index" json:"user_id"`
	Role      string    `gorm:"not null;size:10" json:"role"`
	Content   string    `gorm:"type:text;not null" json:"content"`
	CreatedAt time.Time `json:"created_at"`
}

// Membership 会员模型
type Membership struct {
	ID        string     `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID    string     `gorm:"uniqueIndex;not null" json:"user_id"`
	Plan      string     `gorm:"size:20;default:free" json:"plan"`
	StartedAt *time.Time `json:"started_at"`
	ExpiresAt *time.Time `json:"expires_at"`
	CreatedAt time.Time  `json:"created_at"`
}

// CreateWordRequest 创建单词请求
type CreateWordRequest struct {
	Word       string `json:"word" binding:"required"`
	Meaning    string `json:"meaning"`
	Phonetic   string `json:"phonetic"`
	Example    string `json:"example"`
	Difficulty int    `json:"difficulty"`
	Source     string `json:"source"`
	Tags       string `json:"tags"`
}

// UpdateWordRequest 更新单词请求
type UpdateWordRequest struct {
	Word       string `json:"word"`
	Meaning    string `json:"meaning"`
	Phonetic   string `json:"phonetic"`
	Example    string `json:"example"`
	Difficulty *int   `json:"difficulty"`
	Mastery    *int   `json:"mastery"`
	Source     string `json:"source"`
	Tags       string `json:"tags"`
}

// CreateReviewRequest 创建复习记录请求
type CreateReviewRequest struct {
	WordID string `json:"word_id" binding:"required"`
	Score  int    `json:"score" binding:"required,min=1,max=5"`
}

// PaginatedResponse 分页响应
type PaginatedResponse struct {
	Data  interface{} `json:"data"`
	Total int64       `json:"total"`
	Page  int         `json:"page"`
	Size  int         `json:"size"`
}

// UserStats 用户统计
type UserStats struct {
	TotalWords     int64 `json:"total_words"`
	TotalReviews   int64 `json:"total_reviews"`
	MasteredWords  int64 `json:"mastered_words"`
	CurrentStreak  int   `json:"current_streak"`
	Level          int   `json:"level"`
	Exp            int   `json:"exp"`
}

// ListWords 分页获取单词列表
func ListWords(db *gorm.DB, userID string, page, size int) (*PaginatedResponse, error) {
	var words []Word
	var total int64
	offset := (page - 1) * size
	db.Model(&Word{}).Where("user_id = ?", userID).Count(&total)
	if err := db.Where("user_id = ?", userID).Order("created_at DESC").Offset(offset).Limit(size).Find(&words).Error; err != nil {
		return nil, err
	}
	return &PaginatedResponse{
		Data:  words,
		Total: total,
		Page:  page,
		Size:  size,
	}, nil
}

// CreateWord 创建单词
func CreateWord(db *gorm.DB, userID string, req CreateWordRequest) (*Word, error) {
	word := Word{
		UserID:     userID,
		Word:       req.Word,
		Meaning:    req.Meaning,
		Phonetic:   req.Phonetic,
		Example:    req.Example,
		Difficulty: req.Difficulty,
		Source:     req.Source,
		Tags:       req.Tags,
		Mastery:    0,
	}
	if err := db.Create(&word).Error; err != nil {
		return nil, err
	}
	return &word, nil
}

// GetWordByID 根据ID获取单词
func GetWordByID(db *gorm.DB, userID, wordID string) (*Word, error) {
	var word Word
	if err := db.Where("id = ? AND user_id = ?", wordID, userID).First(&word).Error; err != nil {
		return nil, err
	}
	return &word, nil
}

// UpdateWord 更新单词
func UpdateWord(db *gorm.DB, userID, wordID string, req UpdateWordRequest) (*Word, error) {
	var word Word
	if err := db.Where("id = ? AND user_id = ?", wordID, userID).First(&word).Error; err != nil {
		return nil, err
	}
	updates := map[string]interface{}{}
	if req.Word != "" {
		updates["word"] = req.Word
	}
	if req.Meaning != "" {
		updates["meaning"] = req.Meaning
	}
	if req.Phonetic != "" {
		updates["phonetic"] = req.Phonetic
	}
	if req.Example != "" {
		updates["example"] = req.Example
	}
	if req.Difficulty != nil {
		updates["difficulty"] = *req.Difficulty
	}
	if req.Mastery != nil {
		updates["mastery"] = *req.Mastery
	}
	if req.Source != "" {
		updates["source"] = req.Source
	}
	if req.Tags != "" {
		updates["tags"] = req.Tags
	}
	if len(updates) > 0 {
		if err := db.Model(&word).Updates(updates).Error; err != nil {
			return nil, err
		}
	}
	return &word, nil
}

// DeleteWord 删除单词
func DeleteWord(db *gorm.DB, userID, wordID string) error {
	result := db.Where("id = ? AND user_id = ?", wordID, userID).Delete(&Word{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

// CreateReview 创建复习记录
func CreateReview(db *gorm.DB, userID string, req CreateReviewRequest) (*Review, error) {
	review := Review{
		WordID:     req.WordID,
		UserID:     userID,
		ReviewTime: time.Now(),
		Score:      req.Score,
	}
	if err := db.Create(&review).Error; err != nil {
		return nil, err
	}
	// 更新单词掌握度
	db.Model(&Word{}).Where("id = ? AND user_id = ?", req.WordID, userID).
		UpdateColumn("mastery", gorm.Expr("LEAST(100, mastery + ?)", req.Score*5))
	return &review, nil
}

// GetDueReviews 获取到期复习的单词
func GetDueReviews(db *gorm.DB, userID string) ([]Word, error) {
	var words []Word
	// 简单策略：掌握度 < 80 且 24小时内未复习的单词
	subQuery := db.Model(&Review{}).
		Select("word_id").
		Where("user_id = ? AND review_time > ?", userID, time.Now().Add(-24*time.Hour)).
		Group("word_id")
	if err := db.Where("user_id = ? AND mastery < 80 AND id NOT IN (?)", userID, subQuery).
		Order("mastery ASC").Limit(20).Find(&words).Error; err != nil {
		return nil, err
	}
	return words, nil
}

// GetUserStats 获取用户统计
func GetUserStats(db *gorm.DB, userID string) *UserStats {
	stats := &UserStats{}
	db.Model(&Word{}).Where("user_id = ?", userID).Count(&stats.TotalWords)
	db.Model(&Review{}).Where("user_id = ?", userID).Count(&stats.TotalReviews)
	db.Model(&Word{}).Where("user_id = ? AND mastery >= 80", userID).Count(&stats.MasteredWords)
	return stats
}

// GetUserAchievements 获取用户成就
func GetUserAchievements(db *gorm.DB, userID string) ([]Achievement, error) {
	var achievements []Achievement
	if err := db.Where("user_id = ?", userID).Order("created_at DESC").Find(&achievements).Error; err != nil {
		return nil, err
	}
	return achievements, nil
}
