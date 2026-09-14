import { PlantModel } from '../common/models/PlantModel';
import { SpeciesModel } from '../common/models/SpeciesModel';
import { DateUtil } from '../common/utils/DateUtil';

@Component
export struct AddPlantDialog {
  @Prop isDark: boolean = false;
  @Prop speciesList: SpeciesModel[] = [];
  @Prop editingPlant: PlantModel | null = null;
  onSave?: (plant: PlantModel) => void;
  onClose?: () => void;

  @State selectedSpeciesId: string = '';
  @State plantName: string = '';
  @State nickname: string = '';
  @State location: string = '阳台散光区';
  @State potSize: string = '中盆(18cm)';
  @State icon: string = '🌿';
  @State waterInterval: number = 5;
  @State fertilizeInterval: number = 20;
  @State notes: string = '';

  private readonly LOCATIONS: string[] = ['阳台散光区', '客厅向阳处', '书房案头', '卧室窗台', '办公室桌面', '庭院露养'];
  private readonly POT_SIZES: string[] = ['微型盆(8cm)', '小盆(12cm)', '中盆(18cm)', '大盆(25cm+)'];

  aboutToAppear(): void {
    if (this.editingPlant) {
      this.selectedSpeciesId = this.editingPlant.speciesId;
      this.plantName = this.editingPlant.name;
      this.nickname = this.editingPlant.nickname;
      this.location = this.editingPlant.location;
      this.potSize = this.editingPlant.potSize;
      this.icon = this.editingPlant.icon;
      this.waterInterval = this.editingPlant.waterInterval;
      this.fertilizeInterval = this.editingPlant.fertilizeInterval;
      this.notes = this.editingPlant.notes;
    } else if (this.speciesList.length > 0) {
      const defaultSpecies = this.speciesList[0];
      this.selectedSpeciesId = defaultSpecies.id;
      this.plantName = defaultSpecies.name;
      this.nickname = `我的${defaultSpecies.name}`;
      this.icon = defaultSpecies.icon;
      this.waterInterval = defaultSpecies.suggestWaterDays;
      this.fertilizeInterval = defaultSpecies.suggestFertilizeDays;
    }
  }

  private handleSelectSpecies(species: SpeciesModel): void {
    this.selectedSpeciesId = species.id;
    this.plantName = species.name;
    if (!this.editingPlant) {
      this.nickname = `我的${species.name}`;
      this.icon = species.icon;
      this.waterInterval = species.suggestWaterDays;
      this.fertilizeInterval = species.suggestFertilizeDays;
    }
  }

  private submit(): void {
    const today = DateUtil.formatDate();
    const finalPlant: PlantModel = {
      id: this.editingPlant ? this.editingPlant.id : `plt_${Date.now()}`,
      speciesId: this.selectedSpeciesId,
      name: this.plantName || '新花草',
      nickname: this.nickname || this.plantName || '小绿意',
      location: this.location,
      potSize: this.potSize,
      icon: this.icon,
      acquireDate: this.editingPlant ? this.editingPlant.acquireDate : today,
      waterInterval: this.waterInterval > 0 ? this.waterInterval : 5,
      fertilizeInterval: this.fertilizeInterval > 0 ? this.fertilizeInterval : 20,
      lastWaterDate: this.editingPlant ? this.editingPlant.lastWaterDate : today,
      lastFertilizeDate: this.editingPlant ? this.editingPlant.lastFertilizeDate : today,
      healthStatus: this.editingPlant ? this.editingPlant.healthStatus : 'thriving',
      notes: this.notes,
      isFavorite: this.editingPlant ? this.editingPlant.isFavorite : false
    };

    if (this.onSave) {
      this.onSave(finalPlant);
    }
  }

  private getLocationOptions(): SelectOption[] {
    const list: SelectOption[] = [];
    for (let i = 0; i < this.LOCATIONS.length; i++) {
      const opt: SelectOption = { value: this.LOCATIONS[i] };
      list.push(opt);
    }
    return list;
  }

  private getPotSizeOptions(): SelectOption[] {
    const list: SelectOption[] = [];
    for (let i = 0; i < this.POT_SIZES.length; i++) {
      const opt: SelectOption = { value: this.POT_SIZES[i] };
      list.push(opt);
    }
    return list;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 半透明背景遮罩
      Rect()
        .width('100%')
        .height('100%')
        .fill(this.isDark ? 'rgba(0, 0, 0, 0.70)' : 'rgba(20, 15, 30, 0.45)')
        .onClick(() => {
          if (this.onClose) {
            this.onClose();
          }
        })

      // 弹窗本体
      Column() {
        // 弹窗头部
        Row() {
          Text(this.editingPlant ? '🪴 编辑花盆档案' : '🌱 添置新绿进花园')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

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
        .padding({ bottom: 14 })

        Scroll() {
          Column({ space: 14 }) {
            // 1. 选择对应百科花种
            Column({ space: 6 }) {
              Text('选择花种（自动关联百科与养护建议）')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.speciesList, (species: SpeciesModel) => {
                    Row({ space: 4 }) {
                      Text(species.icon)
                        .fontSize(14)
                      Text(species.name)
                        .fontSize(12)
                        .fontColor(this.selectedSpeciesId === species.id ? '#FFFFFF' : (this.isDark ? '#DCD8EA' : '#2D2A3F'))
                    }
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .borderRadius(12)
                    .backgroundColor(
                      this.selectedSpeciesId === species.id
                        ? (this.isDark ? '#B8985E' : '#C9A96E')
                        : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                    )
                    .onClick(() => {
                      this.handleSelectSpecies(species);
                    })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 2. 爱称
            Column({ space: 6 }) {
              Text('花草爱称')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextInput({ text: this.nickname, placeholder: '为它起个温柔的名字，如「小绿」' })
                .fontSize(13)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(10)
                .onChange((value: string) => {
                  this.nickname = value;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 3. 摆放位置与花盆规格
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text('摆放位置')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Select(this.getLocationOptions())
                  .selected(this.LOCATIONS.indexOf(this.location))
                  .value(this.location)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .font({ size: 12 })
                  .onSelect((index: number, text: string) => {
                    this.location = text;
                  })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Column({ space: 6 }) {
                Text('花盆尺寸')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Select(this.getPotSizeOptions())
                  .selected(this.POT_SIZES.indexOf(this.potSize))
                  .value(this.potSize)
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .font({ size: 12 })
                  .onSelect((index: number, text: string) => {
                    this.potSize = text;
                  })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            // 4. 周期设置
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text('浇水周期 (天)')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Row({ space: 6 }) {
                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    Text('－')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      .textAlign(TextAlign.Center)
                  }
                  .width(32)
                  .height(32)
                  .padding(0)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.06)')
                  .border({ width: 1, color: this.isDark ? 'rgba(212, 184, 126, 0.25)' : 'rgba(168, 135, 74, 0.20)' })
                  .onClick(() => {
                    if (this.waterInterval > 1) {
                      this.waterInterval--;
                    }
                  })

                  Text(`${this.waterInterval} 天`)
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                    .borderRadius(6)
                    .textAlign(TextAlign.Center)

                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    Text('＋')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                      .textAlign(TextAlign.Center)
                  }
                  .width(32)
                  .height(32)
                  .padding(0)
                  .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.18)' : 'rgba(201, 169, 110, 0.18)')
                  .border({ width: 1, color: this.isDark ? 'rgba(212, 184, 126, 0.40)' : 'rgba(201, 169, 110, 0.35)' })
                  .onClick(() => {
                    this.waterInterval++;
                  })
                }
                .alignItems(VerticalAlign.Center)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Column({ space: 6 }) {
                Text('施肥周期 (天)')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Row({ space: 6 }) {
                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    Text('－')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      .textAlign(TextAlign.Center)
                  }
                  .width(32)
                  .height(32)
                  .padding(0)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.06)')
                  .border({ width: 1, color: this.isDark ? 'rgba(142, 224, 208, 0.25)' : 'rgba(35, 78, 82, 0.20)' })
                  .onClick(() => {
                    if (this.fertilizeInterval > 5) {
                      this.fertilizeInterval -= 5;
                    }
                  })

                  Text(`${this.fertilizeInterval} 天`)
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                    .borderRadius(6)
                    .textAlign(TextAlign.Center)

                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    Text('＋')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#8EE0D0' : '#2D8A75')
                      .textAlign(TextAlign.Center)
                  }
                  .width(32)
                  .height(32)
                  .padding(0)
                  .backgroundColor(this.isDark ? 'rgba(142, 224, 208, 0.18)' : 'rgba(45, 138, 117, 0.15)')
                  .border({ width: 1, color: this.isDark ? 'rgba(142, 224, 208, 0.40)' : 'rgba(45, 138, 117, 0.35)' })
                  .onClick(() => {
                    this.fertilizeInterval += 5;
                  })
                }
                .alignItems(VerticalAlign.Center)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            // 5. 备注心得
            Column({ space: 6 }) {
              Text('养护心得与初见备注')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextArea({ text: this.notes, placeholder: '记录购买地点、苗情、土壤配比等...' })
                .fontSize(13)
                .height(72)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(10)
                .onChange((value: string) => {
                  this.notes = value;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
        }
        .constraintSize({ maxHeight: 380 })
        .scrollBar(BarState.Off)

        // 底部确认按钮
        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(42)
            .fontSize(14)
            .fontColor(this.isDark ? '#A29DC0' : '#6B6780')
            .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.05)')
            .borderRadius(14)
            .onClick(() => {
              if (this.onClose) {
                this.onClose();
              }
            })

          Button('确认收进花园')
            .layoutWeight(1)
            .height(42)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
            .borderRadius(14)
            .onClick(() => {
              this.submit();
            })
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('90%')
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
    .width('100%')
    .height('100%')
  }
}
