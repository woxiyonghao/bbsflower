import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
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

  private confirmDeletePlant(): void {
    if (!this.plant) {
      return;
    }
    const plantName = this.plant.nickname;
    promptAction.showDialog({
      title: '移出花木确认',
      message: `确定要将「${plantName}」移出花园吗？相关的日常打卡足迹将一并清除。`,
      buttons: [
        { text: '取消', color: this.isDark ? '#A29DC0' : '#8E8AA3' },
        { text: '确认移出', color: '#E05252' }
      ]
    }).then((result) => {
      if (result.index === 1 && this.plant) {
        StorageService.getInstance().deletePlant(this.plant.id);
        promptAction.showToast({ message: `已将「${plantName}」移出花园`, duration: 1500 });
        setTimeout(() => {
          router.back();
        }, 300);
      }
    }).catch(() => {});
  }

  build() {
    Column() {
      // 1. 顶部 Navigation Header (Stack 确保标题绝对居中)
      Stack({ alignContent: Alignment.Center }) {
        // 绝对居中标题
        Text(this.plant ? this.plant.nickname : '花盆档案')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('60%')

        // 两侧导航与操作
        Row() {
          Button('❮ 返回')
            .fontSize(14)
            .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
            .backgroundColor('transparent')
            .onClick(() => {
              router.back();
            })

          Blank()

          Button('移出')
            .fontSize(13)
            .fontColor('#E05252')
            .backgroundColor('transparent')
            .onClick(() => {
              this.confirmDeletePlant();
            })
        }
        .width('100%')
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
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

                  Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
                    StatBadge({ text: this.plant.location, icon: '📍', colorScheme: 'gold', isDark: this.isDark })
                      .margin({ right: 6, bottom: 4 })
                    StatBadge({ text: this.plant.potSize, icon: '🪴', colorScheme: 'violet', isDark: this.isDark })
                      .margin({ bottom: 4 })
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

                Row({ space: 6 }) {
                  Button({ type: ButtonType.Normal, stateEffect: true }) {
                    Row({ space: 2 }) {
                      Text('💧').fontSize(11)
                      Text('浇水')
                        .fontSize(11)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                    }
                  }
                  .layoutWeight(1)
                  .height(36)
                  .padding({ left: 2, right: 2 })
                  .backgroundColor(this.isDark ? '#2B4A6F' : '#3577B8')
                  .borderRadius(12)
                  .onClick(() => {
                    this.doCareAction('water', '浇水');
                  })

                  Button({ type: ButtonType.Normal, stateEffect: true }) {
                    Row({ space: 2 }) {
                      Text('🌿').fontSize(11)
                      Text('施肥')
                        .fontSize(11)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                    }
                  }
                  .layoutWeight(1)
                  .height(36)
                  .padding({ left: 2, right: 2 })
                  .backgroundColor(this.isDark ? '#234E45' : '#419B7A')
                  .borderRadius(12)
                  .onClick(() => {
                    this.doCareAction('fertilize', '施肥');
                  })

                  Button({ type: ButtonType.Normal, stateEffect: true }) {
                    Row({ space: 2 }) {
                      Text('💨').fontSize(11)
                      Text('喷雾')
                        .fontSize(11)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                    }
                  }
                  .layoutWeight(1)
                  .height(36)
                  .padding({ left: 2, right: 2 })
                  .backgroundColor(this.isDark ? '#43346A' : '#7F67B2')
                  .borderRadius(12)
                  .onClick(() => {
                    this.doCareAction('mist', '叶面喷雾');
                  })

                  Button({ type: ButtonType.Normal, stateEffect: true }) {
                    Row({ space: 2 }) {
                      Text('✂️').fontSize(11)
                      Text('修剪')
                        .fontSize(11)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                    }
                  }
                  .layoutWeight(1)
                  .height(36)
                  .padding({ left: 2, right: 2 })
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

        // 3. 底部操作区：编辑花木档案
        Row() {
          Button('✏️ 编辑花木档案')
            .layoutWeight(1)
            .height(44)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDark ? '#1C1508' : '#FFFFFF')
            .backgroundColor(this.isDark ? '#D4B87E' : '#A8874A')
            .borderRadius(22)
            .shadow({
              radius: 10,
              color: this.isDark ? 'rgba(212, 184, 126, 0.25)' : 'rgba(168, 135, 74, 0.25)',
              offsetY: 3
            })
            .onClick(() => {
              if (this.plant) {
                router.pushUrl({
                  url: 'pages/AddPlantPage',
                  params: { editingPlant: this.plant }
                });
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 18 })
        .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')
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
