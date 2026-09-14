import router from '@ohos.router';
import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtil } from '../common/utils/DateUtil';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';

interface RetrofitCarePageParams {
  date?: string;
  plantId?: string;
}

interface ActionItem {
  type: string;
  name: string;
  icon: string;
  color: string;
}

@Entry
@Component
struct RetrofitCarePage {
  @State isDark: boolean = false;
  @State plants: PlantModel[] = [];
  @State selectedPlantId: string = '';
  @State selectedAction: string = 'water';
  @State dateStr: string = '';
  @State timeStr: string = '12:00';
  @State note: string = '历史日期补记打卡';

  private readonly ACTIONS: ActionItem[] = [
    { type: 'water', name: '浇水', icon: '💧', color: '#3A7EC2' },
    { type: 'fertilize', name: '施肥', icon: '🌿', color: '#3BA785' },
    { type: 'prune', name: '修剪', icon: '✂️', color: '#B8823B' },
    { type: 'mist', name: '喷雾', icon: '💨', color: '#7F67B2' }
  ];

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.plants = StorageService.getInstance().getPlants();

    const params = router.getParams() as RetrofitCarePageParams;
    if (params && params.date) {
      this.dateStr = params.date;
    } else {
      this.dateStr = DateUtil.formatDate();
    }

    if (params && params.plantId) {
      this.selectedPlantId = params.plantId;
    } else if (this.plants.length > 0) {
      this.selectedPlantId = this.plants[0].id;
    }
  }

  private getSelectedActionName(): string {
    const act = this.ACTIONS.find(a => a.type === this.selectedAction);
    return act ? act.name : '养护';
  }

  private submit(): void {
    const plant = this.plants.find(p => p.id === this.selectedPlantId);
    if (!plant) {
      router.back();
      return;
    }

    const actionName = this.getSelectedActionName();
    const log: CareLogModel = {
      id: `log_${Date.now()}`,
      plantId: plant.id,
      plantName: plant.nickname,
      actionType: this.selectedAction,
      actionName: actionName,
      date: this.dateStr.trim() || DateUtil.formatDate(),
      time: this.timeStr.trim() || '12:00',
      note: this.note.trim() || '补记养护记录'
    };

    StorageService.getInstance().addCareLog(log);
    router.back();
  }

  build() {
    Column() {
      // 1. 顶部 Header
      Row() {
        Button('❮ 返回')
          .fontSize(14)
          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text('补记养护打卡')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        // 占位平衡返回按钮
        Row()
          .width(52)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      Scroll() {
        Column({ space: 16 }) {
          // 2. 补记日期设置
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 10 }) {
              Row({ space: 6 }) {
                Text('📅')
                  .fontSize(16)
                Text('补记日期与时间')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
              }

              Row({ space: 10 }) {
                Column({ space: 4 }) {
                  Text('日期 (YYYY-MM-DD)')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  TextInput({ text: this.dateStr })
                    .fontSize(13)
                    .height(40)
                    .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                    .borderRadius(10)
                    .onChange((val: string) => {
                      this.dateStr = val;
                    })
                }
                .layoutWeight(3)
                .alignItems(HorizontalAlign.Start)

                Column({ space: 4 }) {
                  Text('时间')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  TextInput({ text: this.timeStr })
                    .fontSize(13)
                    .height(40)
                    .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                    .borderRadius(10)
                    .onChange((val: string) => {
                      this.timeStr = val;
                    })
                }
                .layoutWeight(2)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 3. 选择花草
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 12 }) {
              Row({ space: 6 }) {
                Text('🪴')
                  .fontSize(16)
                Text('选择呵护的花木')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
              }

              if (this.plants.length === 0) {
                Text('花园中暂无花草，请先前往花园添置')
                  .fontSize(12)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              } else {
                Scroll() {
                  Row({ space: 10 }) {
                    ForEach(this.plants, (plant: PlantModel) => {
                      Row({ space: 8 }) {
                        PlantIcon({ plantName: plant.name, sizeVal: 32, isDark: this.isDark, showSubBadge: false })
                        Column({ space: 2 }) {
                          Text(plant.nickname)
                            .fontSize(13)
                            .fontWeight(this.selectedPlantId === plant.id ? FontWeight.Bold : FontWeight.Normal)
                            .fontColor(this.selectedPlantId === plant.id ? '#FFFFFF' : (this.isDark ? '#F2EFF9' : '#2D2A3F'))
                          Text(plant.location)
                            .fontSize(10)
                            .fontColor(this.selectedPlantId === plant.id ? '#F0EAD6' : (this.isDark ? '#A29DC0' : '#8E8AA3'))
                        }
                        .alignItems(HorizontalAlign.Start)
                      }
                      .padding({ left: 10, right: 14, top: 8, bottom: 8 })
                      .borderRadius(16)
                      .backgroundColor(
                        this.selectedPlantId === plant.id
                          ? (this.isDark ? '#B8985E' : '#C9A96E')
                          : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                      )
                      .onClick(() => {
                        this.selectedPlantId = plant.id;
                      })
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 4. 养护动作类型
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 12 }) {
              Row({ space: 6 }) {
                Text('✨')
                  .fontSize(16)
                Text('养护动作类型')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
              }

              Row({ space: 8 }) {
                ForEach(this.ACTIONS, (act: ActionItem) => {
                  Row({ space: 4 }) {
                    Text(act.icon)
                      .fontSize(13)
                    Text(act.name)
                      .fontSize(12)
                      .fontWeight(this.selectedAction === act.type ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.selectedAction === act.type ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
                  }
                  .justifyContent(FlexAlign.Center)
                  .layoutWeight(1)
                  .height(40)
                  .borderRadius(12)
                  .backgroundColor(
                    this.selectedAction === act.type
                      ? act.color
                      : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                  )
                  .stateStyles({
                    pressed: {
                      .scale({ x: 0.96, y: 0.96 })
                      .opacity(0.85)
                    },
                    normal: {
                      .scale({ x: 1.0, y: 1.0 })
                      .opacity(1.0)
                    }
                  })
                  .animation({ duration: 150, curve: Curve.EaseOut })
                  .onClick(() => {
                    this.selectedAction = act.type;
                  })
                })
              }
              .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 5. 养护备注
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 8 }) {
              Text('养护心得与备注 (选填)')
                .fontSize(12)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextArea({ text: this.note, placeholder: '记录水分渗透、叶面清洁情况等...' })
                .fontSize(13)
                .height(80)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(10)
                .onChange((val: string) => {
                  this.note = val;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 底部保存大按钮
          Button('确认补记入册')
            .width('100%')
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
            .borderRadius(16)
            .margin({ top: 8, bottom: 24 })
            .stateStyles({
              pressed: {
                .scale({ x: 0.97, y: 0.97 })
                .opacity(0.88)
              },
              normal: {
                .scale({ x: 1.0, y: 1.0 })
                .opacity(1.0)
              }
            })
            .animation({ duration: 150, curve: Curve.EaseOut })
            .onClick(() => {
              this.submit();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
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
