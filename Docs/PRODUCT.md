# Reson

## Product Vision

Reson — это адаптивная система достижения целей.

Пользователь описывает, чего хочет добиться, указывает срок и доступное время. Приложение создаёт план, раскладывает его по дням, отслеживает выполнение и автоматически перестраивает маршрут после пропусков.

Reson — не обычный task manager. Его задача — довести пользователя от цели до результата.

---

## Core Problem

Люди часто понимают, чего хотят, но не знают:

- с чего начать;
- что делать каждый день;
- как распределить нагрузку;
- что делать после пропусков;
- успевают ли они к дедлайну.

Обычные планировщики только хранят задачи. Reson самостоятельно формирует и адаптирует путь к цели.

---

## Core User Flow

1. Пользователь создаёт цель.
2. Указывает дедлайн и доступное время.
3. Reson задаёт уточняющие вопросы.
4. AI создаёт план достижения цели.
5. Пользователь проверяет и подтверждает план.
6. План разбивается на этапы и ежедневные задачи.
7. Reson показывает задачи на сегодня.
8. Пользователь выполняет, переносит или пропускает задачу.
9. При пропуске Reson уточняет причину.
10. Оставшийся план автоматически перестраивается.
11. Прогресс и прогноз достижения цели обновляются.

---

## Unique Features

### Adaptive Plan Engine

План меняется в зависимости от реального поведения пользователя.

### Daily Execution Plan

Каждый день пользователь получает конкретный набор задач с длительностью и приоритетом.

### One Next Action

Reson выделяет одно главное действие, которое нужно выполнить сейчас.

### Recovery Mode

После нескольких пропущенных дней приложение не создаёт гору просроченных задач, а формирует новый реалистичный план.

### Goal Forecast

Приложение показывает текущий темп и вероятность достижения цели к дедлайну.

### AI Check-ins

Reson периодически спрашивает о прогрессе, сложности задач и причинах пропусков.

---

## Main Screens

### Today

- главное действие;
- задачи на сегодня;
- длительность задач;
- выполнение, перенос и пропуск;
- краткий дневной прогресс.

### Goals

- список активных целей;
- дедлайн;
- общий прогресс;
- текущий этап;
- прогноз достижения.

### Goal Details

- описание цели;
- этапы;
- полный план;
- связанные задачи;
- история изменений;
- редактирование нагрузки.

### Coach

- создание цели;
- уточняющие вопросы;
- генерация плана;
- изменение плана;
- AI check-ins;
- помощь после пропусков.

### Progress

- выполненные задачи;
- пропущенные задачи;
- текущий темп;
- серии дней;
- прогресс по целям;
- прогноз достижения.

### Settings

- доступное время;
- рабочие часы;
- выходные дни;
- уведомления;
- предпочтительная нагрузка;
- настройки AI.

---

## MVP Features

- создание цели;
- дедлайн;
- доступное время;
- локальное хранение целей;
- создание плана;
- подтверждение плана;
- ежедневные задачи;
- выполнение задач;
- перенос задач;
- пропуск задач;
- восстановление завершённых задач;
- связь задач с целями;
- отслеживание прогресса;
- базовая перестройка плана после пропуска.

---

## Post-MVP Features

- реальный AI API;
- умная генерация персональных планов;
- автоматическая адаптация нагрузки;
- прогноз достижения цели;
- уведомления;
- календарная интеграция;
- Focus Timer;
- блокировка отвлекающих приложений;
- виджеты;
- Apple Watch;
- CloudKit;
- социальная система;
- шаблоны целей;
- accountability partner;
- подписка.

---

## Navigation

Основные вкладки приложения:

1. Today
2. Goals
3. Coach
4. Progress
5. Settings

Текущие Tasks и Board будут переиспользованы внутри новой структуры, а не удалены.

---

## Data Models

### Goal

- title
- description
- targetDate
- createdAt
- status
- progress
- availableMinutesPerDay

### Plan

- goal
- createdAt
- updatedAt
- status
- milestones

### Milestone

- title
- order
- targetDate
- isCompleted

### Task

- title
- notes
- dueDate
- estimatedMinutes
- priority
- status
- goal
- milestone

### CheckIn

- date
- task
- result
- skipReason
- userComment

---

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- MVVM
- Xcode
- iOS Simulator
- Git
- GitHub
- OpenAI API later
- UserNotifications later
- EventKit later
- CloudKit later
- StoreKit 2 later

---

## Development Plan

### Phase 1 — Product Foundation

- product documentation;
- navigation structure;
- core models;
- local persistence.

### Phase 2 — Goals

- create goal;
- edit goal;
- delete goal;
- goal details;
- deadline and available time.

### Phase 3 — Plan Generation

- clarification questions;
- plan preview;
- plan approval;
- milestones;
- generated tasks.

### Phase 4 — Daily Execution

- Today screen;
- daily task selection;
- task duration;
- one next action;
- task completion.

### Phase 5 — Adaptation

- skipped task reasons;
- automatic rescheduling;
- recovery mode;
- workload recalculation.

### Phase 6 — Progress

- goal progress;
- daily statistics;
- streaks;
- completion forecast.

### Phase 7 — AI Integration

- AI-generated plans;
- AI check-ins;
- AI plan adaptation;
- response validation.

### Phase 8 — Product Quality

- design system;
- animations;
- onboarding;
- notifications;
- testing;
- App Store preparation.

---

## MVP Success Criteria

Пользователь может:

1. создать цель;
2. указать срок и доступное время;
3. получить план;
4. подтвердить его;
5. увидеть задачи на сегодня;
6. выполнить или пропустить задачу;
7. получить обновлённый план после пропуска;
8. увидеть прогресс по цели;
9. сохранить данные после перезапуска приложения.

---

## Current Status

- проект собирается;
- используется SwiftUI и SwiftData;
- реализована навигация из пяти вкладок;
- реализованы задачи;
- реализованы проекты;
- задачи можно завершать и восстанавливать;
- завершённые задачи скрываются из активного списка;
- локальная генерация цели и пяти тестовых задач работает;
- данные сохраняются локально.

---

## Product Rule

Любая новая функция должна помогать пользователю быстрее и стабильнее двигаться к цели.

Не добавлять функции, которые превращают Reson в обычный список задач.
