import router from '@ohos.router';
import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtil } from '../common/utils/DateUtil';
import { CareScheduler } from '../common/utils/CareScheduler';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';

interface PlantDetailPageParams {
  plantId: string;
}

@Entry
@Component
struct PlantDetailPage {
  @State isDark: boolean = false;
  @State plantId: string = '';
  @State plant: PlantModel | null = null;
  @State careLogs: CareLogModel[] = [];
  @State diaries: DiaryModel[] = [];

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    const params = router.getParams() as PlantDetailPageParams;
    if (params && params.plantId) {
      this.plantId = params.plantId;
    }
    this.loadData();
  }

  onPageShow(): void {
    this.loadData();
  }

  private loadData(): void {
    const storage = StorageService.getInstance();
    if (this.plantId) {
      this.plant = storage.getPlantById(this.plantId);
      this.careLogs = storage.getCareLogs().filter(l => l.plantId === this.plantId);
      this.diaries = storage.getDiaries().filter(d => d.plantId === this.plantId);
    }
  }

  private getDaysSinceAcquire(): number {
    if (!this.plant) {
      return 0;
    }
    const today = DateUtil.formatDate();
    const days = DateUtil.diffDays(today, this.plant.acquireDate);
    return Math.max(days, 1);
  }

  private doCareAction(actionType: string, actionName: string): void {
    if (!this.plant) {
      return;
    }
    const today = DateUtil.formatDate();
    const time = DateUtil.formatTime();
    const log: CareLogModel = {
      id: `log_${Date.now()}`,
      plantId: this.plant.id,
      plantName: this.plant.nickname,
      actionType: actionType,
      actionName: actionName,
      date: today,
      time: time,
      note: `为${this.plant.nickname}进行${actionName}`
    };
    StorageService.getInstance().addCareLog(log);
    this.loadData();
  }

  private deletePlant(): void {
    if (this.plant) {
      StorageService.getInstance().deletePlant(this.plant.id);
      router.back();
    }
  }

  build() {
    Column() {
      // 1. 顶部 Navigation Header
      Row() {
        Button('❮ 返回')
          .fontSize(14)
          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text(this.plant ? this.plant.nickname : '花盆档案')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        Row({ space: 8 }) {
          Button('编辑')
            .fontSize(13)
            .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
            .backgroundColor('transparent')
            .onClick(() => {
              if (this.plant) {
                router.pushUrl({
                  url: 'pages/AddPlantPage',
                  params: { editingPlant: this.plant }
                });
              }
            })

          Button('移出')
            .fontSize(13)
            .fontColor('#E05252')
            .backgroundColor('transparent')
            .onClick(() => {
              this.deletePlant();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      if (this.plant) {
        Scroll() {
          Column({ space: 16 }) {
            // 1. 植物名片卡
            GlassCard({ isDark: this.isDark, radius: 24, paddingVal: 20 }) {
              Row({ space: 16 }) {
                PlantIcon({ plantName: this.plant.name, sizeVal: 68, isDark: this.isDark })

                Column({ space: 4 }) {
                  Row({ space: 6 }) {
                    Text(this.plant.nickname)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                    if (this.plant.isFavorite) {
                      Text('⭐').fontSize(14)
                    }
                  }

                  Text(`${this.plant.name} · 入手第 ${this.getDaysSinceAcquire()} 天`)
                    .fontSize(12)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                  Row({ space: 6 }) {
                    StatBadge({ text: this.plant.location, icon: '📍', colorScheme: 'gold', isDark: this.isDark })
                    StatBadge({ text: this.plant.potSize, icon: '🪴', colorScheme: 'violet', isDark: this.isDark })
                  }
                  .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
            }

            // 2. 状态倒计时看板
            Row({ space: 10 }) {
              // 浇水指示
              Column({ space: 4 }) {
                Text('💧 下次浇水')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')
                Text(DateUtil.getRemainingDaysDesc(CareScheduler.getNextWaterDate(this.plant), DateUtil.formatDate()))
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                Text(`周期 ${this.plant.waterInterval} 天 / 上次 ${this.plant.lastWaterDate}`)
                  .fontSize(10)
                  .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
              }
              .layoutWeight(1)
              .padding(12)
              .borderRadius(16)
              .backgroundColor(this.isDark ? 'rgba(120, 180, 240, 0.12)' : '#F0F6FC')
              .alignItems(HorizontalAlign.Start)

              // 施肥指示
              Column({ space: 4 }) {
                Text('🌿 下次施肥')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#8EE0D0' : '#234E52')
                Text(DateUtil.getRemainingDaysDesc(CareScheduler.getNextFertilizeDate(this.plant), DateUtil.formatDate()))
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                Text(`周期 ${this.plant.fertilizeInterval} 天 / 上次 ${this.plant.lastFertilizeDate}`)
                  .fontSize(10)
                  .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
              }
              .layoutWeight(1)
              .padding(12)
              .borderRadius(16)
              .backgroundColor(this.isDark ? 'rgba(110, 220, 200, 0.12)' : '#EEF9F5')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            // 3. 快捷养护动作栏
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
              Column({ space: 10 }) {
                Text('日常养护打卡')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                Row({ space: 8 }) {
                  Button('💧 浇水')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .backgroundColor(this.isDark ? '#2B4A6F' : '#3577B8')
                    .borderRadius(12)
                    .onClick(() => {
                      this.doCareAction('water', '浇水');
                    })

                  Button('🌿 施肥')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .backgroundColor(this.isDark ? '#234E45' : '#419B7A')
                    .borderRadius(12)
                    .onClick(() => {
                      this.doCareAction('fertilize', '施肥');
                    })

                  Button('💨 喷雾')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(12)
                    .backgroundColor(this.isDark ? '#43346A' : '#7F67B2')
                    .borderRadius(12)
                    .onClick(() => {
                      this.doCareAction('mist', '叶面喷雾');
                    })

                  Button('✂️ 修剪')
                    .layoutWeight(1)
                    .height(36)
                    .fontSize(12)
                    .backgroundColor(this.isDark ? '#6E4522' : '#B8823B')
                    .borderRadius(12)
                    .onClick(() => {
                      this.doCareAction('prune', '枝叶修剪');
                    })
                }
                .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 4. 养护手记与心得
            if (this.plant.notes && this.plant.notes.length > 0) {
              GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
                Column({ space: 6 }) {
                  Text('初始见闻与备注')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                  Text(this.plant.notes)
                    .fontSize(13)
                    .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                    .lineHeight(20)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
            }

            // 5. 专属成长日记
            Column({ space: 10 }) {
              Row() {
                Text(`成长日记 (${this.diaries.length})`)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

                Blank()

                Button('＋ 记一篇')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
                  .borderRadius(12)
                  .height(30)
                  .padding({ left: 10, right: 10 })
                  .onClick(() => {
                    if (this.plant) {
                      router.pushUrl({
                        url: 'pages/AddDiaryPage',
                        params: { defaultPlantId: this.plant.id }
                      });
                    }
                  })
              }
              .width('100%')

              if (this.diaries.length === 0) {
                GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 20 }) {
                  Text('暂未记录该花草的成长手记，点击右上角开始记录。')
                    .fontSize(12.5)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    .textAlign(TextAlign.Center)
                    .width('100%')
                }
              } else {
                ForEach(this.diaries, (diary: DiaryModel) => {
                  GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 14 }) {
                    Column({ space: 6 }) {
                      Row() {
                        Text(`${diary.mood} ${diary.title}`)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                        Blank()

                        Text(diary.date)
                          .fontSize(11)
                          .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                      }
                      .width('100%')

                      Text(diary.content)
                        .fontSize(12.5)
                        .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                        .lineHeight(18)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width('100%')
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/DiaryDetailPage',
                        params: { diaryId: diary.id }
                      });
                    })
                  }
                })
              }
            }
            .width('100%')

            // 6. 养护打卡历史
            Column({ space: 10 }) {
              Text(`养护日志 (${this.careLogs.length})`)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              if (this.careLogs.length === 0) {
                GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 20 }) {
                  Text('暂未记录养护足迹，点击上方快捷动作完成第一次打卡。')
                    .fontSize(12.5)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    .textAlign(TextAlign.Center)
                    .width('100%')
                }
              } else {
                ForEach(this.careLogs, (log: CareLogModel) => {
                  GlassCard({ isDark: this.isDark, radius: 14, paddingVal: 12 }) {
                    Row({ space: 8 }) {
                      Text(log.actionType === 'water' ? '💧' : (log.actionType === 'fertilize' ? '🌿' : '✂️'))
                        .fontSize(14)

                      Text(log.actionName)
                        .fontSize(13)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                      if (log.note && log.note.length > 0) {
                        Text(` - ${log.note}`)
                          .fontSize(12)
                          .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                      }

                      Blank()

                      Text(`${log.date} ${log.time}`)
                        .fontSize(11)
                        .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    }
                    .width('100%')
                  }
                })
              }
            }
            .width('100%')
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#100D1C' : '#FAF6F0')
  }

  pageTransition() {
    // 1. Push 进入当前页：从右边向左滑入
    PageTransitionEnter({ type: RouteType.Push, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
      .opacity(0)
    // 2. Pop 退出当前页返回上一级：向右边滑出
    PageTransitionExit({ type: RouteType.Pop, duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
      .opacity(0)
    // 3. 作为前置页面被更深级 Push 压栈时退出：向左边滑出
    PageTransitionExit({ type: RouteType.Push, duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
      .opacity(0)
    // 4. 更深级页面 Pop 返回时当前页面恢复：从左边滑入
    PageTransitionEnter({ type: RouteType.Pop, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Left)
      .opacity(0)
  }
}
