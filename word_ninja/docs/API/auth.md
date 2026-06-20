# Word Ninja — API 文档

## 认证 /api/v1/auth

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /auth/login | 登录 |
| POST | /auth/register | 注册 |
| POST | /auth/refresh | 刷新 Token |

## 单词 /api/v1/words

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /words | 获取单词列表 |
| POST | /words | 创建单词 |
| GET | /words/:id | 获取单词详情 |
| PUT | /words/:id | 更新单词 |
| DELETE | /words/:id | 删除单词 |
| GET | /words/review/due | 待复习单词 |
| POST | /words/review/:id | 提交复习评分 |

## AI /api/v1/ai

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /ai/chat | AI 对话 |
| POST | /ai/explain | 单词解释 |
| POST | /ai/plan | 生成学习计划 |
| POST | /ai/correct | 作文批改 |

## 用户 /api/v1/users

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /users/me | 当前用户信息 |
| PUT | /users/me | 更新资料 |
| GET | /users/me/stats | 学习统计 |
| GET | /users/me/achievements | 成就列表 |
