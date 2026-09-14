import router from '@ohos.router';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { PlantModel } from '../common/models/PlantModel';
import { DateUtil, CalendarDayInfo } from '../common/utils/DateUtil';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';

@Component
export struct CalendarTab {
  @Prop isDark: boolean = false;
  @Prop careLogs: CareLogModel[] = [];
  @Prop diaries: DiaryModel[] = [];
  @Prop plants: PlantModel[] = [];
  onAddPastCareLog?: (plant: PlantModel, actionType: string, dateStr: string) => void;

  @State currentYear: number = 2026;
  @State currentMonth: number = 9;
  @State selectedDateStr: string = '';

  private readonly WEEK_HEADERS: string[] = ['日', '一', '二', '三', '四', '五', '六'];

  aboutToAppear(): void {
    const today = new Date();
    this.currentYear = today.getFullYear();
    this.currentMonth = today.getMonth() + 1;
    this.selectedDateStr = DateUtil.formatDate(today);
  }

  private prevMonth(): void {
    if (this.currentMonth === 1) {
      this.currentMonth = 12;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
  }

  private nextMonth(): void {
    if (this.currentMonth === 12) {
      this.currentMonth = 1;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
  }

  private getCalendarDays(): CalendarDayInfo[] {
    const careDates = this.careLogs.map(l => l.date);
    const diaryDates = this.diaries.map(d => d.date);
    return DateUtil.generateMonthGrid(this.currentYear, this.currentMonth, careDates, diaryDates);
  }

  private getSelectedDateCareLogs(): CareLogModel[] {
    return this.careLogs.filter(l => l.date === this.selectedDateStr);
  }

  private getSelectedDateDiaries(): DiaryModel[] {
    return this.diaries.filter(d => d.date === this.selectedDateStr);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 16 }) {
          // 1. 顶部 Header 与月份选择
          Row() {
            Column({ space: 2 }) {
              Text('养护日历')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
              Text('记录四时流转，留存每一次甘霖滋养')
                .fontSize(12)
                .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Button('＋ 补记打卡')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
              .borderRadius(14)
              .height(32)
              .padding({ left: 12, right: 12 })
              .stateStyles({
                pressed: {
                  .scale({ x: 0.94, y: 0.94 })
                  .opacity(0.85)
                },
                normal: {
                  .scale({ x: 1.0, y: 1.0 })
                  .opacity(1.0)
                }
              })
              .animation({ duration: 150, curve: Curve.EaseOut })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/RetrofitCarePage',
                  params: { date: this.selectedDateStr }
                });
              })
          }
          .width('100%')
          .padding({ top: 12, bottom: 4 })

          // 2. 日历卡片
          GlassCard({ isDark: this.isDark, radius: 22, paddingVal: 16 }) {
            Column({ space: 12 }) {
              // 月份控制器
              Row() {
                Button('❮')
                  .width(32)
                  .height(32)
                  .fontSize(14)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .backgroundColor('transparent')
                  .onClick(() => { this.prevMonth(); })

                Text(`${this.currentYear}年 ${this.currentMonth}月`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                Button('❯')
                  .width(32)
                  .height(32)
                  .fontSize(14)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .backgroundColor('transparent')
                  .onClick(() => { this.nextMonth(); })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')

              // 星期表头
              GridRow({ columns: 7 }) {
                ForEach(this.WEEK_HEADERS, (w: string) => {
                  GridCol() {
                    Text(w)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                      .textAlign(TextAlign.Center)
                      .width('100%')
                      .padding({ top: 4, bottom: 4 })
                  }
                })
              }
              .width('100%')

              // 日期单元格网格
              GridRow({ columns: 7, gutter: 4 }) {
                ForEach(this.getCalendarDays(), (day: CalendarDayInfo) => {
                  GridCol() {
                    Column({ space: 2 }) {
                      Text(`${day.dayNum}`)
                        .fontSize(13)
                        .fontWeight(day.isToday ? FontWeight.Bold : FontWeight.Normal)
                        .fontColor(
                          day.dateStr === this.selectedDateStr
                            ? '#FFFFFF'
                            : (day.isCurrentMonth
                              ? (this.isDark ? '#F2EFF9' : '#2D2A3F')
                              : (this.isDark ? '#4F4B66' : '#C5C1D4'))
                        )

                      // 打卡与日记指示圆点
                      Row({ space: 2 }) {
                        if (day.hasCareAction) {
                          Circle({ width: 4, height: 4 })
                            .fill(day.dateStr === this.selectedDateStr ? '#FFFFFF' : (this.isDark ? '#8EE0D0' : '#388E6D'))
                        }
                        if (day.hasDiary) {
                          Circle({ width: 4, height: 4 })
                            .fill(day.dateStr === this.selectedDateStr ? '#FFFFFF' : (this.isDark ? '#E8A0BF' : '#B3587E'))
                        }
                      }
                      .height(6)
                    }
                    .width('100%')
                    .height(42)
                    .borderRadius(10)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(
                      day.dateStr === this.selectedDateStr
                        ? (this.isDark ? '#B8985E' : '#C9A96E')
                        : (day.isToday
                          ? (this.isDark ? 'rgba(212,184,126,0.18)' : 'rgba(201,169,110,0.18)')
                          : 'transparent')
                    )
                    .onClick(() => {
                      this.selectedDateStr = day.dateStr;
                    })
                  }
                })
              }
              .width('100%')
            }
            .width('100%')
          }

          // 3. 养护频率热力图看板
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 14 }) {
            Column({ space: 8 }) {
              Row() {
                Text('🌱 养护热力图')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                Blank()
                Text(`本月累计打卡 ${this.careLogs.filter(l => l.date.indexOf(`${this.currentYear}-${this.currentMonth < 10 ? '0' + this.currentMonth : this.currentMonth}`) === 0).length} 次`)
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              }
              .width('100%')

              // 热力条展示
              Row({ space: 4 }) {
                ForEach(this.getCalendarDays().filter(d => d.isCurrentMonth), (d: CalendarDayInfo) => {
                  Column()
                    .layoutWeight(1)
                    .height(20)
                    .borderRadius(4)
                    .backgroundColor(
                      d.actionCount >= 3
                        ? '#2E8B57'
                        : (d.actionCount >= 1
                          ? (this.isDark ? '#5BA88A' : '#7BC4A8')
                          : (this.isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.04)'))
                    )
                })
              }
              .width('100%')
            }
            .width('100%')
          }

          // 4. 选中日期的足迹详情卡片
          Column({ space: 10 }) {
            Row() {
              Text(`📅 ${this.selectedDateStr} 养护足迹`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Blank()

              if (this.getSelectedDateCareLogs().length > 0 || this.getSelectedDateDiaries().length > 0) {
                Text(`${this.getSelectedDateCareLogs().length}项养护 · ${this.getSelectedDateDiaries().length}篇日记`)
                  .fontSize(11)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
              }
            }
            .width('100%')

            if (this.getSelectedDateCareLogs().length === 0 && this.getSelectedDateDiaries().length === 0) {
              GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 20 }) {
                Text('这一天草木静默生长，暂无养护打卡与日记')
                  .fontSize(13)
                  .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                  .textAlign(TextAlign.Center)
                  .width('100%')
              }
            } else {
              Column({ space: 8 }) {
                // 打卡记录列表
                ForEach(this.getSelectedDateCareLogs(), (log: CareLogModel) => {
                  GlassCard({ isDark: this.isDark, radius: 14, paddingVal: 12 }) {
                    Row({ space: 10 }) {
                      Text(log.actionType === 'water' ? '💧' : (log.actionType === 'fertilize' ? '🌿' : '✂️'))
                        .fontSize(20)

                      Column({ space: 2 }) {
                        Text(`为「${log.plantName}」完成${log.actionName}`)
                          .fontSize(13)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                        if (log.note && log.note.length > 0) {
                          Text(log.note)
                            .fontSize(11)
                            .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Text(log.time)
                        .fontSize(11)
                        .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    }
                    .width('100%')
                  }
                })

                // 日记记录列表
                ForEach(this.getSelectedDateDiaries(), (diary: DiaryModel) => {
                  GlassCard({ isDark: this.isDark, radius: 14, paddingVal: 12 }) {
                    Column({ space: 4 }) {
                      Row() {
                        Text(`${diary.mood} ${diary.title}`)
                          .fontSize(13)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                        Blank()
                        StatBadge({ text: diary.tagName, colorScheme: 'violet', isDark: this.isDark })
                      }
                      .width('100%')

                      Text(diary.content)
                        .fontSize(12)
                        .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                        .lineHeight(18)
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  }
                })
              }
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 96 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
