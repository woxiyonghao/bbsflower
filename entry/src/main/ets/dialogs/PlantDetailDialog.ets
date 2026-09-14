import { PlantModel } from '../common/models/PlantModel';
import { CareLogModel } from '../common/models/CareLogModel';
import { DiaryModel } from '../common/models/DiaryModel';
import { DateUtil } from '../common/utils/DateUtil';
import { CareScheduler } from '../common/utils/CareScheduler';
import { StatBadge } from '../common/components/StatBadge';

@Component
export struct PlantDetailDialog {
  @Prop isDark: boolean = false;
  @Prop plant: PlantModel | null = null;
  @Prop careLogs: CareLogModel[] = [];
  @Prop diaries: DiaryModel[] = [];
  onClose?: () => void;
  onEdit?: (plant: PlantModel) => void;
  onDelete?: (plantId: string) => void;
  onCareAction?: (plant: PlantModel, actionType: string, actionName: string) => void;
  onAddDiary?: (plant: PlantModel) => void;

  private getPlantCareLogs(): CareLogModel[] {
    if (!this.plant) {
      return [];
    }
    return this.careLogs.filter(l => l.plantId === this.plant?.id);
  }

  private getPlantDiaries(): DiaryModel[] {
    if (!this.plant) {
      return [];
    }
    return this.diaries.filter(d => d.plantId === this.plant?.id);
  }

  private getDaysSinceAcquire(): number {
    if (!this.plant) {
      return 0;
    }
    const today = DateUtil.formatDate();
    const days = DateUtil.diffDays(today, this.plant.acquireDate);
    return Math.max(days, 1);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 遮罩
      Rect()
        .width('100%')
        .height('100%')
        .fill(this.isDark ? 'rgba(0, 0, 0, 0.70)' : 'rgba(20, 15, 30, 0.45)')
        .onClick(() => {
          if (this.onClose) {
            this.onClose();
          }
        })

      if (this.plant) {
        Column() {
          // 头部
          Row() {
            Row({ space: 10 }) {
              Text(this.plant.icon)
                .fontSize(28)
              Column({ space: 4 }) {
                Text(this.plant.nickname)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                Row({ space: 6 }) {
                  Text(this.plant.name)
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                  Text('·')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                  Text(`陪伴 ${this.getDaysSinceAcquire()} 天`)
                    .fontSize(12)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                }
              }
              .alignItems(HorizontalAlign.Start)
            }

            Blank()

            Button('✕')
              .fontSize(16)
              .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              .backgroundColor('transparent')
              .onClick(() => {
                if (this.onClose) {
                  this.onClose();
                }
              })
          }
          .width('100%')
          .padding({ bottom: 12 })

          Scroll() {
            Column({ space: 16 }) {
              // 1. 状态指示看板
              Row({ space: 10 }) {
                // 浇水指示
                Column({ space: 4 }) {
                  Text('💧 下次浇水')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')
                  Text(DateUtil.getRemainingDaysDesc(CareScheduler.getNextWaterDate(this.plant), DateUtil.formatDate()))
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  Text(`周期 ${this.plant.waterInterval} 天 / 上次 ${this.plant.lastWaterDate}`)
                    .fontSize(10)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                }
                .layoutWeight(1)
                .padding(10)
                .borderRadius(12)
                .backgroundColor(this.isDark ? 'rgba(120, 180, 240, 0.12)' : '#F0F6FC')
                .alignItems(HorizontalAlign.Start)

                // 施肥指示
                Column({ space: 4 }) {
                  Text('🌿 下次施肥')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#8EE0D0' : '#234E52')
                  Text(DateUtil.getRemainingDaysDesc(CareScheduler.getNextFertilizeDate(this.plant), DateUtil.formatDate()))
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  Text(`周期 ${this.plant.fertilizeInterval} 天 / 上次 ${this.plant.lastFertilizeDate}`)
                    .fontSize(10)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                }
                .layoutWeight(1)
                .padding(10)
                .borderRadius(12)
                .backgroundColor(this.isDark ? 'rgba(110, 220, 200, 0.12)' : '#EEF9F5')
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')

              // 2. 快捷养护动作栏
              Column({ space: 8 }) {
                Text('快捷养护打卡')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

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
                    if (this.onCareAction && this.plant) {
                      this.onCareAction(this.plant, 'water', '浇水');
                    }
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
                    if (this.onCareAction && this.plant) {
                      this.onCareAction(this.plant, 'fertilize', '施肥');
                    }
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
                    if (this.onCareAction && this.plant) {
                      this.onCareAction(this.plant, 'mist', '叶面喷雾');
                    }
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
                    if (this.onCareAction && this.plant) {
                      this.onCareAction(this.plant, 'prune', '枝叶修剪');
                    }
                  })
                }
                .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              // 3. 档案详情参数
              Column({ space: 8 }) {
                Text('档案参数')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Row() {
                  StatBadge({ text: `位置: ${this.plant.location}`, icon: '📍', colorScheme: 'gold', isDark: this.isDark })
                  Blank().width(6)
                  StatBadge({ text: `盆径: ${this.plant.potSize}`, icon: '🪴', colorScheme: 'violet', isDark: this.isDark })
                  Blank().width(6)
                  StatBadge({ text: '生长旺盛', icon: '✨', colorScheme: 'green', isDark: this.isDark })
                }

                if (this.plant.notes && this.plant.notes.length > 0) {
                  Text(this.plant.notes)
                    .fontSize(12)
                    .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                    .lineHeight(18)
                    .padding(8)
                    .borderRadius(8)
                    .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.03)')
                    .width('100%')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              // 4. 专属成长日记
              Column({ space: 8 }) {
                Row() {
                  Text('成长日记轨迹')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                  Blank()

                  Text('+ 写篇日记')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                    .onClick(() => {
                      if (this.onAddDiary && this.plant) {
                        this.onAddDiary(this.plant);
                      }
                    })
                }
                .width('100%')

                if (this.getPlantDiaries().length === 0) {
                  Text('暂未记录该植物的独立观察笔记')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    .padding({ top: 4, bottom: 4 })
                } else {
                  ForEach(this.getPlantDiaries(), (diary: DiaryModel) => {
                    Column({ space: 4 }) {
                      Row() {
                        Text(`${diary.mood} ${diary.title}`)
                          .fontSize(13)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                        Blank()
                        Text(diary.date)
                          .fontSize(11)
                          .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                      }
                      .width('100%')

                      Text(diary.content)
                        .fontSize(12)
                        .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
                        .lineHeight(18)
                    }
                    .padding(10)
                    .borderRadius(10)
                    .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.02)')
                    .width('100%')
                    .alignItems(HorizontalAlign.Start)
                  })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              // 5. 养护打卡历史
              Column({ space: 8 }) {
                Text('养护日志')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                if (this.getPlantCareLogs().length === 0) {
                  Text('暂无养护打卡记录')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                } else {
                  ForEach(this.getPlantCareLogs().slice(0, 5), (log: CareLogModel) => {
                    Row() {
                      Text(`• ${log.actionName}`)
                        .fontSize(12)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
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
                    .padding({ top: 3, bottom: 3 })
                  })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }
          .constraintSize({ maxHeight: 380 })
          .scrollBar(BarState.Off)

          // 底部操作栏
          Row({ space: 12 }) {
            Button('🗑️ 移出花园')
              .height(38)
              .fontSize(13)
              .fontColor('#E05252')
              .backgroundColor(this.isDark ? 'rgba(224, 82, 82, 0.15)' : '#FDE8E8')
              .borderRadius(12)
              .onClick(() => {
                if (this.onDelete && this.plant) {
                  this.onDelete(this.plant.id);
                }
              })

            Blank()

            Button('✏️ 编辑档案')
              .height(38)
              .fontSize(13)
              .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
              .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.05)')
              .borderRadius(12)
              .onClick(() => {
                if (this.onEdit && this.plant) {
                  this.onEdit(this.plant);
                }
              })
          }
          .width('100%')
          .margin({ top: 16 })
        }
        .width('92%')
        .padding(20)
        .borderRadius(24)
        .backgroundColor(this.isDark ? '#1C162E' : '#FFFFFF')
        .borderWidth(1)
        .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.16)' : 'rgba(255, 255, 255, 0.85)')
        .shadow({
          radius: 30,
          color: this.isDark ? 'rgba(0,0,0,0.6)' : 'rgba(90, 70, 140, 0.16)',
          offsetY: 10
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
