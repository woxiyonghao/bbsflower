import router from '@ohos.router';
import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { DAILY_QUOTES, DailyQuote } from '../common/constants/DefaultWikiData';
import { DateUtil } from '../common/utils/DateUtil';
import { CareScheduler, CareTaskItem } from '../common/utils/CareScheduler';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';
import { EmptyState } from '../common/components/EmptyState';

@Component
export struct HomeTab {
  @Prop isDark: boolean = false;
  @Prop plants: PlantModel[] = [];
  @Prop careLogs: CareLogModel[] = [];
  @Prop diaries: DiaryModel[] = [];
  @Prop streakDays: number = 0;

  onOpenAddPlant?: () => void;
  onOpenAddDiary?: () => void;
  onOpenShareSummary?: () => void;
  onSwitchTab?: (tabIndex: number) => void;
  onQuickCare?: (task: CareTaskItem) => void;
  onToggleTheme?: () => void;

  @State quoteIndex: number = 0;

  aboutToAppear(): void {
    // 每日根据日期哈希得到今日花语初始索引
    const today = DateUtil.formatDate();
    let hash = 0;
    for (let i = 0; i < today.length; i++) {
      hash = (hash * 31 + today.charCodeAt(i)) % DAILY_QUOTES.length;
    }
    this.quoteIndex = Math.abs(hash);
  }

  private nextQuote(): void {
    this.quoteIndex = (this.quoteIndex + 1) % DAILY_QUOTES.length;
  }

  private getDueTasks(): CareTaskItem[] {
    return CareScheduler.generateDueTasks(this.plants);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 1. 顶部 Header
        Row() {
          Column({ space: 2 }) {
            Text('琉璃花语')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
            Text(`${DateUtil.getChineseDate()} · 静听花开`)
              .fontSize(12)
              .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Row({ space: 8 }) {
            // 连续打卡标签
            StatBadge({
              text: `${this.streakDays} 天连续`,
              icon: '🔥',
              colorScheme: 'gold',
              isDark: this.isDark
            })

            // 主题切换按钮
            Button(this.isDark ? '☀️' : '🌙')
              .width(36)
              .height(36)
              .fontSize(16)
              .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.10)' : 'rgba(0, 0, 0, 0.05)')
              .borderRadius(18)
              .onClick(() => {
                if (this.onToggleTheme) {
                  this.onToggleTheme();
                }
              })
          }
        }
        .width('100%')
        .padding({ top: 12, bottom: 4 })

        // 2. 每日花语卡片
        GlassCard({ isDark: this.isDark, radius: 22, paddingVal: 16 }) {
          Column({ space: 10 }) {
            Row() {
              Row({ space: 6 }) {
                Text('🌸')
                  .fontSize(16)
                Text('每日花语')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
                Text(`· ${DAILY_QUOTES[this.quoteIndex].flower}`)
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              }

              Blank()

              Text('换一句 ↻')
                .fontSize(11)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                .onClick(() => {
                  this.nextQuote();
                })
            }
            .width('100%')

            Text(`“${DAILY_QUOTES[this.quoteIndex].quote}”`)
              .fontSize(14)
              .fontWeight(FontWeight.Normal)
              .lineHeight(22)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
              .width('100%')
              .textAlign(TextAlign.Start)

            Row() {
              Blank()
              Text(`—— ${DAILY_QUOTES[this.quoteIndex].source}`)
                .fontSize(11)
                .fontStyle(FontStyle.Italic)
                .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
            }
            .width('100%')
          }
          .width('100%')
        }

        // 3. 核心统计看板
        GridRow({ columns: 4, gutter: 8 }) {
          // 花园藏株
          GridCol() {
            Column({ space: 2 }) {
              Text(`${this.plants.length}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')
              Text('在养花木')
                .fontSize(11)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
            }
            .padding({ top: 10, bottom: 10 })
            .borderRadius(14)
            .backgroundColor(this.isDark ? 'rgba(110, 220, 200, 0.12)' : '#EBF7F3')
            .width('100%')
            .onClick(() => {
              if (this.onSwitchTab) {
                this.onSwitchTab(1); // 跳转到花园 Tab
              }
            })
          }

          // 今日待办
          GridCol() {
            Column({ space: 2 }) {
              Text(`${this.getDueTasks().length}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#E4CC94' : '#A8874A')
              Text('待办养护')
                .fontSize(11)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
            }
            .padding({ top: 10, bottom: 10 })
            .borderRadius(14)
            .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.12)' : '#FDF4E5')
            .width('100%')
          }

          // 坚持天数
          GridCol() {
            Column({ space: 2 }) {
              Text(`${this.streakDays}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#C4B4EE' : '#5E4A8C')
              Text('连续坚守')
                .fontSize(11)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
            }
            .padding({ top: 10, bottom: 10 })
            .borderRadius(14)
            .backgroundColor(this.isDark ? 'rgba(166, 150, 208, 0.12)' : '#F2EEFA')
            .width('100%')
            .onClick(() => {
              if (this.onSwitchTab) {
                this.onSwitchTab(2); // 跳转到日历 Tab
              }
            })
          }

          // 累积打卡
          GridCol() {
            Column({ space: 2 }) {
              Text(`${this.careLogs.length}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#9CC8F0' : '#3577B8')
              Text('滋养总数')
                .fontSize(11)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
            }
            .padding({ top: 10, bottom: 10 })
            .borderRadius(14)
            .backgroundColor(this.isDark ? 'rgba(120, 180, 240, 0.12)' : '#EAF3FC')
            .width('100%')
            .onClick(() => {
              if (this.onOpenShareSummary) {
                this.onOpenShareSummary();
              }
            })
          }
        }
        .width('100%')

        // 4. 今日待办养护任务模块
        Column({ space: 10 }) {
          Row() {
            Text('今日待办养护')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

            Blank()

            if (this.getDueTasks().length > 0) {
              Text(`${this.getDueTasks().length} 项待处理`)
                .fontSize(12)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
            }
          }
          .width('100%')

          if (this.getDueTasks().length === 0) {
            GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 20 }) {
              Row({ space: 12 }) {
                Text('🍃')
                  .fontSize(28)
                Column({ space: 4 }) {
                  Text('今日花园草木安然，无需养护')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  Text('所有植物皆在适宜周期内，去泡杯茶，享受绿意吧。')
                    .fontSize(11.5)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }
          } else {
            Column({ space: 8 }) {
              ForEach(this.getDueTasks(), (task: CareTaskItem) => {
                GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 12 }) {
                  Row({ space: 10 }) {
                    PlantIcon({ plantName: task.plantName, sizeVal: 40, isDark: this.isDark })

                    Column({ space: 3 }) {
                      Row({ space: 6 }) {
                        Text(task.nickname)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                        StatBadge({
                          text: task.statusDesc,
                          colorScheme: task.isOverdue ? 'petal' : 'gold',
                          isDark: this.isDark
                        })
                      }

                      Text(`${task.plantName} · ${task.location}`)
                        .fontSize(11)
                        .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Button(`完成${task.actionName}`)
                      .fontSize(12)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .backgroundColor(
                        task.actionType === 'water'
                          ? (this.isDark ? '#305480' : '#3A7EC2')
                          : (this.isDark ? '#2E6152' : '#3BA785')
                      )
                      .borderRadius(12)
                      .height(34)
                      .padding({ left: 12, right: 12 })
                      .onClick(() => {
                        if (this.onQuickCare) {
                          this.onQuickCare(task);
                        }
                      })
                  }
                  .width('100%')
                }
              })
            }
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 5. 快捷功能金刚区
        Row({ space: 10 }) {
          // 添置花草
          Column({ space: 6 }) {
            Text('🪴')
              .fontSize(22)
            Text('添置花盆')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(16)
          .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : '#FFFFFF')
          .borderWidth(1)
          .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddPlantPage' });
          })

          // 记录日记
          Column({ space: 6 }) {
            Text('📝')
              .fontSize(22)
            Text('记篇日记')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(16)
          .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : '#FFFFFF')
          .borderWidth(1)
          .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddDiaryPage' });
          })

          // 百花图鉴
          Column({ space: 6 }) {
            Text('📚')
              .fontSize(22)
            Text('百花图鉴')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(16)
          .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : '#FFFFFF')
          .borderWidth(1)
          .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            if (this.onSwitchTab) {
              this.onSwitchTab(3); // 百科 Tab
            }
          })

          // 时光回顾
          Column({ space: 6 }) {
            Text('✨')
              .fontSize(22)
            Text('绿意回顾')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(16)
          .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : '#FFFFFF')
          .borderWidth(1)
          .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            router.pushUrl({ url: 'pages/ShareSummaryPage' });
          })
        }
        .width('100%')

        // 6. 最近养护足迹
        if (this.careLogs.length > 0) {
          Column({ space: 8 }) {
            Row() {
              Text('最近养护足迹')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Blank()

              Text('查看日历 →')
                .fontSize(12)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                .onClick(() => {
                  if (this.onSwitchTab) {
                    this.onSwitchTab(2);
                  }
                })
            }
            .width('100%')

            ForEach(this.careLogs.slice(0, 3), (log: CareLogModel) => {
              Row({ space: 10 }) {
                Text(log.actionType === 'water' ? '💧' : (log.actionType === 'fertilize' ? '🌿' : '✂️'))
                  .fontSize(16)

                Column({ space: 2 }) {
                  Text(`为「${log.plantName}」完成${log.actionName}`)
                    .fontSize(13)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  if (log.note && log.note.length > 0) {
                    Text(log.note)
                      .fontSize(11)
                      .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(`${log.date} ${log.time}`)
                  .fontSize(11)
                  .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .borderWidth({ bottom: 1 })
              .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
            })
          }
          .width('100%')
          .padding({ top: 6 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
