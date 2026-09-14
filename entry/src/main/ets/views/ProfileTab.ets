import router from '@ohos.router';
import { BadgeModel } from '../common/models/BadgeModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { BadgeEngine } from '../common/utils/BadgeEngine';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';

@Component
export struct ProfileTab {
  @Prop isDark: boolean = false;
  @Prop themeMode: string = 'system'; // 'system' | 'light' | 'dark'
  @Prop plants: PlantModel[] = [];
  @Prop careLogs: CareLogModel[] = [];
  @Prop diaries: DiaryModel[] = [];
  @Prop streakDays: number = 0;

  onChangeThemeMode?: (mode: string) => void;
  onOpenAddDiary?: () => void;
  onDeleteDiary?: (id: string) => void;
  onResetData?: () => void;
  onExportData?: () => void;
  onImportData?: (jsonStr: string) => void;
  onOpenShareSummary?: () => void;

  @State currentSection: string = 'badges'; // 'badges', 'diaries', 'settings'
  @State showBackupDialog: boolean = false;
  @State backupJsonText: string = '';
  @State isExportMode: boolean = true; // true: export, false: import

  private getBadges(): BadgeModel[] {
    return BadgeEngine.getAllBadges(this.plants, this.careLogs, this.diaries, this.streakDays);
  }

  private getUnlockedBadgeCount(): number {
    return this.getBadges().filter(b => b.isUnlocked).length;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 16 }) {
          // 1. 顶部用户绿意卡片
          GlassCard({ isDark: this.isDark, radius: 24, paddingVal: 20 }) {
            Column({ space: 12 }) {
              Row({ space: 14 }) {
                Text('🌸')
                  .fontSize(40)
                  .padding(10)
                  .borderRadius(20)
                  .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.15)' : '#FDF2E2')

                Column({ space: 4 }) {
                  Text('琉璃雅舍')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

                  Text('一花一世界，一叶一菩提 · 单机绿意守护')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                  Row({ space: 6 }) {
                    StatBadge({ text: '完全离线', icon: '🔒', colorScheme: 'green', isDark: this.isDark })
                    StatBadge({ text: '零账号', icon: '🛡️', colorScheme: 'gold', isDark: this.isDark })
                    StatBadge({ text: '永久免费', icon: '🎁', colorScheme: 'petal', isDark: this.isDark })
                  }
                  .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')

              // 荣誉成就总览条
              Row() {
                Column({ space: 2 }) {
                  Text(`${this.getUnlockedBadgeCount()} / ${this.getBadges().length}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
                  Text('解锁成就')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                }
                .layoutWeight(1)

                Column({ space: 2 }) {
                  Text(`${this.streakDays} 天`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')
                  Text('连续养护')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                }
                .layoutWeight(1)

                Column({ space: 2 }) {
                  Text(`${this.diaries.length} 篇`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#C4B4EE' : '#5E4A8C')
                  Text('草木日记')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 10, bottom: 4 })
              .borderWidth({ top: 1 })
              .borderColor(this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.04)')
            }
            .width('100%')
          }

          // 2. 栏目切换 Tab 按钮
          Row({ space: 8 }) {
            Button('🏆 成就徽章')
              .fontSize(13)
              .fontColor(this.currentSection === 'badges' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
              .backgroundColor(this.currentSection === 'badges' ? (this.isDark ? '#B8985E' : '#C9A96E') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.04)'))
              .borderRadius(14)
              .height(34)
              .layoutWeight(1)
              .onClick(() => { this.currentSection = 'badges'; })

            Button('📖 日记本')
              .fontSize(13)
              .fontColor(this.currentSection === 'diaries' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
              .backgroundColor(this.currentSection === 'diaries' ? (this.isDark ? '#B8985E' : '#C9A96E') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.04)'))
              .borderRadius(14)
              .height(34)
              .layoutWeight(1)
              .onClick(() => { this.currentSection = 'diaries'; })

            Button('⚙️ 系统设置')
              .fontSize(13)
              .fontColor(this.currentSection === 'settings' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
              .backgroundColor(this.currentSection === 'settings' ? (this.isDark ? '#B8985E' : '#C9A96E') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.04)'))
              .borderRadius(14)
              .height(34)
              .layoutWeight(1)
              .onClick(() => { this.currentSection = 'settings'; })
          }
          .width('100%')

          // 3. 栏目内容区域
          if (this.currentSection === 'badges') {
            // 成就徽章墙
            Column({ space: 10 }) {
              GridRow({ columns: 2, gutter: 10 }) {
                ForEach(this.getBadges(), (badge: BadgeModel) => {
                  GridCol() {
                    GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 14 }) {
                      Column({ space: 6 }) {
                        Row() {
                          Text(badge.icon)
                            .fontSize(28)
                          Blank()
                          StatBadge({
                            text: badge.isUnlocked ? '已达成' : `${badge.current}/${badge.target}`,
                            colorScheme: badge.isUnlocked ? 'gold' : 'gray',
                            isDark: this.isDark
                          })
                        }
                        .width('100%')

                        Text(badge.name)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(badge.isUnlocked ? (this.isDark ? '#F2EFF9' : '#2D2A3F') : (this.isDark ? '#736F90' : '#8E8AA3'))

                        Text(badge.description)
                          .fontSize(11)
                          .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                          .lineHeight(16)
                      }
                      .alignItems(HorizontalAlign.Start)
                      .width('100%')
                    }
                  }
                })
              }
            }
            .width('100%')
          } else if (this.currentSection === 'diaries') {
            // 日记列表
            Column({ space: 10 }) {
              Row() {
                Text(`共 ${this.diaries.length} 篇成长笔记`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

                Blank()

                Button('＋ 记一篇')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
                  .borderRadius(12)
                  .height(30)
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/AddDiaryPage' });
                  })
              }
              .width('100%')

              if (this.diaries.length === 0) {
                GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 20 }) {
                  Text('暂未记录成长日记，点击右上角写下第一抹新绿吧。')
                    .fontSize(13)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    .textAlign(TextAlign.Center)
                    .width('100%')
                }
              } else {
                ForEach(this.diaries, (diary: DiaryModel) => {
                  GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 14 }) {
                    Column({ space: 6 }) {
                      Row() {
                        Row({ space: 6 }) {
                          Text(diary.mood).fontSize(16)
                          Text(diary.title)
                            .fontSize(15)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                        }

                        Blank()

                        StatBadge({ text: diary.tagName, colorScheme: 'petal', isDark: this.isDark })
                      }
                      .width('100%')

                      Row({ space: 8 }) {
                        Text(`植物: ${diary.plantName}`)
                          .fontSize(11)
                          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                        Text('·')
                          .fontSize(11)
                          .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                        Text(`${diary.date} ${diary.time}`)
                          .fontSize(11)
                          .fontColor(this.isDark ? '#736F90' : '#8E8AA3')

                        Blank()

                        Text('删除')
                          .fontSize(11)
                          .fontColor('#E05252')
                          .onClick(() => {
                            if (this.onDeleteDiary) {
                              this.onDeleteDiary(diary.id);
                            }
                          })
                      }
                      .width('100%')

                      Text(diary.content)
                        .fontSize(13)
                        .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                        .lineHeight(20)
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                  }
                })
              }
            }
            .width('100%')
          } else {
            // 系统与个性设置
            Column({ space: 14 }) {
              // 1. 主题模式切换
              GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
                Column({ space: 10 }) {
                  Text('🎨 主题色彩与深色模式')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

                  Text('遵循鸿蒙系统规范，支持随系统深浅设置自动切换，亦可强制常开。')
                    .fontSize(11.5)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                  Row({ space: 10 }) {
                    Button('跟随系统')
                      .fontSize(12)
                      .fontColor(this.themeMode === 'system' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
                      .backgroundColor(this.themeMode === 'system' ? (this.isDark ? '#B8985E' : '#C9A96E') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
                      .borderRadius(12)
                      .layoutWeight(1)
                      .height(34)
                      .onClick(() => {
                        if (this.onChangeThemeMode) {
                          this.onChangeThemeMode('system');
                        }
                      })

                    Button('☀️ 琉璃暖光')
                      .fontSize(12)
                      .fontColor(this.themeMode === 'light' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
                      .backgroundColor(this.themeMode === 'light' ? '#C9A96E' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
                      .borderRadius(12)
                      .layoutWeight(1)
                      .height(34)
                      .onClick(() => {
                        if (this.onChangeThemeMode) {
                          this.onChangeThemeMode('light');
                        }
                      })

                    Button('🌙 沉静夜色')
                      .fontSize(12)
                      .fontColor(this.themeMode === 'dark' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
                      .backgroundColor(this.themeMode === 'dark' ? '#5E4A8C' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
                      .borderRadius(12)
                      .layoutWeight(1)
                      .height(34)
                      .onClick(() => {
                        if (this.onChangeThemeMode) {
                          this.onChangeThemeMode('dark');
                        }
                      })
                  }
                  .width('100%')
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }

              // 2. 本地数据安全与备份
              GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
                Column({ space: 10 }) {
                  Text('💾 本地单机数据备份与恢复')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

                  Text('所有植物档案、养护日志与日记均存储于本机沙盒，全程不经过任何云端服务器。')
                    .fontSize(11.5)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                  Row({ space: 10 }) {
                    Button('✨ 查看时光回顾卡片')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.isDark ? '#305480' : '#3A7EC2')
                      .borderRadius(12)
                      .layoutWeight(1)
                      .height(36)
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/ShareSummaryPage' });
                      })

                    Button('📥 导入备份')
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.isDark ? '#43346A' : '#7F67B2')
                      .borderRadius(12)
                      .layoutWeight(1)
                      .height(36)
                      .onClick(() => {
                        this.isExportMode = false;
                        this.backupJsonText = '';
                        this.showBackupDialog = true;
                      })
                  }
                  .width('100%')

                  Button('↻ 恢复示范花草与日记数据')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                    .backgroundColor('transparent')
                    .height(32)
                    .onClick(() => {
                      if (this.onResetData) {
                        this.onResetData();
                      }
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }

              // 3. 关于琉璃花语
              GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
                Column({ space: 6 }) {
                  Text('🌸 关于 琉璃花语')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

                  Text('版本: V1.0.0 (HarmonyOS 原生单机版)')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                  Text('设计语言: Apple Liquid Glass + 东方花语美学')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                  Text('应用承诺: 无账号 · 无注册 · 完全单机 · 零广告 · 永久免费')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 96 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      // 备份导出/导入弹窗
      if (this.showBackupDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Rect()
            .width('100%')
            .height('100%')
            .fill('rgba(0, 0, 0, 0.65)')
            .onClick(() => { this.showBackupDialog = false; })

          Column({ space: 14 }) {
            Row() {
              Text(this.isExportMode ? '📦 导出备份 JSON' : '📥 导入恢复数据')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

              Blank()

              Button('✕')
                .fontSize(16)
                .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                .backgroundColor('transparent')
                .onClick(() => { this.showBackupDialog = false; })
            }
            .width('100%')

            Text(this.isExportMode ? '以下为全量花园、打卡与日记数据，请复制保存：' : '请粘贴您备份的 JSON 字符串：')
              .fontSize(12)
              .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

            TextArea({ text: this.backupJsonText })
              .fontSize(11)
              .height(180)
              .backgroundColor(this.isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)')
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
              .borderRadius(10)
              .onChange((v: string) => { this.backupJsonText = v; })

            Row({ space: 10 }) {
              Button('关闭')
                .layoutWeight(1)
                .height(38)
                .fontSize(13)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                .backgroundColor(this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)')
                .borderRadius(12)
                .onClick(() => { this.showBackupDialog = false; })

              if (!this.isExportMode) {
                Button('确认导入')
                  .layoutWeight(1)
                  .height(38)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
                  .borderRadius(12)
                  .onClick(() => {
                    if (this.onImportData && this.backupJsonText.trim().length > 0) {
                      this.onImportData(this.backupJsonText);
                    }
                    this.showBackupDialog = false;
                  })
              }
            }
            .width('100%')
          }
          .width('88%')
          .padding(20)
          .borderRadius(22)
          .backgroundColor(this.isDark ? '#1C162E' : '#FFFFFF')
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  public showExportDialogWithText(jsonStr: string): void {
    this.isExportMode = true;
    this.backupJsonText = jsonStr;
    this.showBackupDialog = true;
  }
}
