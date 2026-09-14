import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PlantModel } from '../common/models/PlantModel';
import { SpeciesModel } from '../common/models/SpeciesModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtil } from '../common/utils/DateUtil';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';

interface AddPlantPageParams {
  editingPlant?: PlantModel;
  presetSpecies?: SpeciesModel;
}

@Entry
@Component
struct AddPlantPage {
  @State isDark: boolean = false;
  @State speciesList: SpeciesModel[] = [];
  @State editingPlant: PlantModel | null = null;

  @State selectedSpeciesId: string = '';
  @State plantName: string = '';
  @State nickname: string = '';
  @State location: string = '阳台散光区';
  @State potSize: string = '中盆(18cm)';
  @State waterInterval: number = 5;
  @State fertilizeInterval: number = 20;
  @State notes: string = '';

  private readonly LOCATIONS: string[] = ['阳台散光区', '客厅向阳处', '书房案头', '卧室窗台', '办公室桌面', '庭院露养'];
  private readonly POT_SIZES: string[] = ['微型盆(8cm)', '小盆(12cm)', '中盆(18cm)', '大盆(25cm+)'];

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.speciesList = StorageService.getInstance().getSpecies();

    const params = router.getParams() as AddPlantPageParams;
    if (params && params.editingPlant) {
      this.editingPlant = params.editingPlant;
      this.selectedSpeciesId = params.editingPlant.speciesId;
      this.plantName = params.editingPlant.name;
      this.nickname = params.editingPlant.nickname;
      this.location = params.editingPlant.location;
      this.potSize = params.editingPlant.potSize;
      this.waterInterval = params.editingPlant.waterInterval;
      this.fertilizeInterval = params.editingPlant.fertilizeInterval;
      this.notes = params.editingPlant.notes;
    } else if (params && params.presetSpecies) {
      this.handleSelectSpecies(params.presetSpecies);
    } else if (this.speciesList.length > 0) {
      this.handleSelectSpecies(this.speciesList[0]);
    }
  }

  private handleSelectSpecies(species: SpeciesModel): void {
    this.selectedSpeciesId = species.id;
    this.plantName = species.name;
    if (!this.editingPlant) {
      this.nickname = `我的${species.name}`;
      this.waterInterval = species.suggestWaterDays;
      this.fertilizeInterval = species.suggestFertilizeDays;
      this.notes = `花语：「${species.flowerLanguage}」`;
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

  private submit(): void {
    const today = DateUtil.formatDate();
    const finalPlant: PlantModel = {
      id: this.editingPlant ? this.editingPlant.id : `plt_${Date.now()}`,
      speciesId: this.selectedSpeciesId,
      name: this.plantName || '新花草',
      nickname: this.nickname || this.plantName || '小绿意',
      location: this.location,
      potSize: this.potSize,
      icon: this.plantName,
      acquireDate: this.editingPlant ? this.editingPlant.acquireDate : today,
      waterInterval: this.waterInterval > 0 ? this.waterInterval : 5,
      fertilizeInterval: this.fertilizeInterval > 0 ? this.fertilizeInterval : 20,
      lastWaterDate: this.editingPlant ? this.editingPlant.lastWaterDate : today,
      lastFertilizeDate: this.editingPlant ? this.editingPlant.lastFertilizeDate : today,
      healthStatus: this.editingPlant ? this.editingPlant.healthStatus : 'thriving',
      notes: this.notes,
      isFavorite: this.editingPlant ? this.editingPlant.isFavorite : false
    };

    StorageService.getInstance().savePlant(finalPlant);
    try {
      promptAction.showToast({ message: `✨ 已成功收进我的花园「${finalPlant.nickname}」` });
    } catch (e) {}
    router.back();
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

        Text(this.editingPlant ? '编辑花盆档案' : '添置新花木')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        // 占位平衡返回按钮宽度，确保标题完美居中
        Row()
          .width(52)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      // 2. 表单内容区
      Scroll() {
        Column({ space: 16 }) {
          // 当前植物图标大展示
          Row({ space: 14 }) {
            PlantIcon({ plantName: this.plantName, sizeVal: 64, isDark: this.isDark })

            Column({ space: 4 }) {
              Text(this.plantName)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

              Text('根据百科推荐参数已自动预填养护周期')
                .fontSize(11.5)
                .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(16)
          .borderRadius(20)
          .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.05)' : '#FFFFFF')

          // 1. 选择品种
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 10 }) {
              Text('选择花木品种（点击自动关联）')
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

              Scroll() {
                Row({ space: 10 }) {
                  ForEach(this.speciesList, (sp: SpeciesModel) => {
                    Column({ space: 4 }) {
                      PlantIcon({ plantName: sp.name, sizeVal: 38, isDark: this.isDark, showSubBadge: false })
                      Text(sp.name)
                        .fontSize(11)
                        .fontWeight(this.selectedSpeciesId === sp.id ? FontWeight.Bold : FontWeight.Normal)
                        .fontColor(this.selectedSpeciesId === sp.id ? (this.isDark ? '#D4B87E' : '#A8874A') : (this.isDark ? '#A29DC0' : '#6B6780'))
                    }
                    .padding(8)
                    .borderRadius(14)
                    .backgroundColor(
                      this.selectedSpeciesId === sp.id
                        ? (this.isDark ? 'rgba(212, 184, 126, 0.22)' : '#FDF4E5')
                        : 'transparent'
                    )
                    .onClick(() => {
                      this.handleSelectSpecies(sp);
                    })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 2. 爱称与位置
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 14 }) {
              Column({ space: 6 }) {
                Text('花草爱称 / 昵称')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                TextInput({ text: this.nickname, placeholder: '为它起个温柔名字，如「阳台一号小绿」' })
                  .fontSize(14)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .borderRadius(12)
                  .onChange((val: string) => {
                    this.nickname = val;
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              Row({ space: 12 }) {
                Column({ space: 6 }) {
                  Text('摆放环境')
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
                  Text('花盆规格')
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
            }
            .width('100%')
          }

          // 3. 养护周期推算
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 14 }) {
              Text('养护提醒周期设定')
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

              Row({ space: 12 }) {
                // 浇水周期
                Column({ space: 6 }) {
                  Text('💧 建议浇水周期')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')

                  Row({ space: 8 }) {
                    Button('-')
                      .width(34)
                      .height(34)
                      .fontSize(16)
                      .backgroundColor(this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)')
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      .onClick(() => {
                        if (this.waterInterval > 1) {
                          this.waterInterval--;
                        }
                      })

                    Text(`${this.waterInterval} 天`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')

                    Button('+')
                      .width(34)
                      .height(34)
                      .fontSize(16)
                      .backgroundColor(this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)')
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      .onClick(() => {
                        this.waterInterval++;
                      })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                // 施肥周期
                Column({ space: 6 }) {
                  Text('🌿 建议施肥周期')
                    .fontSize(12)
                    .fontColor(this.isDark ? '#8EE0D0' : '#234E52')

                  Row({ space: 8 }) {
                    Button('-')
                      .width(34)
                      .height(34)
                      .fontSize(16)
                      .backgroundColor(this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)')
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      .onClick(() => {
                        if (this.fertilizeInterval > 5) {
                          this.fertilizeInterval -= 5;
                        }
                      })

                    Text(`${this.fertilizeInterval} 天`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')

                    Button('+')
                      .width(34)
                      .height(34)
                      .fontSize(16)
                      .backgroundColor(this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)')
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      .onClick(() => {
                        this.fertilizeInterval += 5;
                      })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 4. 心得备注
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 6 }) {
              Text('养护心得与初见手记')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextArea({ text: this.notes, placeholder: '记录购买地点、苗情、土壤配比等...' })
                .fontSize(13)
                .height(84)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(10)
                .onChange((val: string) => {
                  this.notes = val;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 底部保存大按钮
          Button(this.editingPlant ? '保存修改' : '确认收进我的花园')
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
