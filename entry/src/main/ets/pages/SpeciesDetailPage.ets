import router from '@ohos.router';
import { SpeciesModel } from '../common/models/SpeciesModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';

interface SpeciesDetailPageParams {
  speciesId: string;
}

@Entry
@Component
struct SpeciesDetailPage {
  @State isDark: boolean = false;
  @State speciesId: string = '';
  @State species: SpeciesModel | null = null;
  @State isInGarden: boolean = false;

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    const params = router.getParams() as SpeciesDetailPageParams;
    if (params && params.speciesId) {
      this.speciesId = params.speciesId;
      this.species = StorageService.getInstance().getSpeciesById(this.speciesId);
      this.checkInGarden();
    }
  }

  onPageShow(): void {
    this.checkInGarden();
  }

  private checkInGarden(): void {
    if (this.species) {
      const plants = StorageService.getInstance().getPlants();
      this.isInGarden = plants.some(p => p.speciesId === this.species?.id || p.name === this.species?.name);
    }
  }

  private addToGarden(): void {
    if (this.species) {
      router.replaceUrl({
        url: 'pages/AddPlantPage',
        params: { presetSpecies: this.species }
      });
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

        Text(this.species ? this.species.name : '百科宝典')
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

      if (this.species) {
        Scroll() {
          Column({ space: 16 }) {
            // 1. 顶部花种名片
            GlassCard({ isDark: this.isDark, radius: 24, paddingVal: 20 }) {
              Row({ space: 16 }) {
                PlantIcon({ plantName: this.species.name, sizeVal: 68, isDark: this.isDark })

                Column({ space: 4 }) {
                  Row({ space: 6 }) {
                    Text(this.species.name)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                    StatBadge({
                      text: this.species.difficultyName,
                      colorScheme: this.species.difficulty === 'easy' ? 'green' : (this.species.difficulty === 'medium' ? 'gold' : 'petal'),
                      isDark: this.isDark
                    })
                  }

                  Text(`${this.species.latinName} · ${this.species.family}`)
                    .fontSize(11.5)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                  Row({ space: 6 }) {
                    StatBadge({ text: `周期~${this.species.suggestWaterDays}天`, icon: '💧', colorScheme: 'blue', isDark: this.isDark })
                    StatBadge({ text: this.species.categoryName, icon: '🏷️', colorScheme: 'violet', isDark: this.isDark })
                  }
                  .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
            }

            // 2. 花语寄语卡片
            Row({ space: 8 }) {
              Text('💌').fontSize(18)
              Text(`花语：「${this.species.flowerLanguage}」`)
                .fontSize(13.5)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#E8A0BF' : '#9B4A6E')
            }
            .width('100%')
            .padding(14)
            .borderRadius(16)
            .backgroundColor(this.isDark ? 'rgba(232, 160, 191, 0.12)' : '#FDF2F7')

            // 3. 简述与植物故事
            GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
              Column({ space: 6 }) {
                Text('植物故事与生态特征')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                Text(this.species.description)
                  .fontSize(13)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(20)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 4. 四大核心养护要素
            Column({ space: 10 }) {
              Text('四维核心养护要素')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              GridRow({ columns: 2, gutter: 10 }) {
                // 光照
                GridCol() {
                  Column({ space: 4 }) {
                    Text('☀️ 光照需求')
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark ? '#D4B87E' : '#8B6914')
                    Text(this.species.light)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                      .lineHeight(17)
                  }
                  .padding(12)
                  .borderRadius(14)
                  .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.12)' : '#FDF7EB')
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }

                // 水分
                GridCol() {
                  Column({ space: 4 }) {
                    Text(`💧 浇水要点 (~${this.species.suggestWaterDays}天)`)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')
                    Text(this.species.waterGuide)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                      .lineHeight(17)
                  }
                  .padding(12)
                  .borderRadius(14)
                  .backgroundColor(this.isDark ? 'rgba(120, 180, 240, 0.12)' : '#F0F6FD')
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }

                // 温度
                GridCol() {
                  Column({ space: 4 }) {
                    Text('🌡️ 适宜温度')
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark ? '#8EE0D0' : '#234E52')
                    Text(this.species.temperature)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                      .lineHeight(17)
                  }
                  .padding(12)
                  .borderRadius(14)
                  .backgroundColor(this.isDark ? 'rgba(110, 220, 200, 0.12)' : '#EFFBF7')
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }

                // 湿度
                GridCol() {
                  Column({ space: 4 }) {
                    Text('🌫️ 空气湿度')
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark ? '#C4B4EE' : '#5E4A8C')
                    Text(this.species.humidity)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#DCD8EA' : '#2D2A3F')
                      .lineHeight(17)
                  }
                  .padding(12)
                  .borderRadius(14)
                  .backgroundColor(this.isDark ? 'rgba(166, 150, 208, 0.12)' : '#F5F1FB')
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 5. 土壤与施肥
            GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
              Column({ space: 6 }) {
                Text('🪴 土壤与施肥指南')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                Text(this.species.soilGuide)
                  .fontSize(12.5)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(19)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 6. 修剪与繁殖
            GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
              Column({ space: 6 }) {
                Text('✂️ 修剪与繁殖诀窍')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                Text(this.species.pruneGuide)
                  .fontSize(12.5)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(19)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 7. 常见病害及应对
            GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
              Column({ space: 6 }) {
                Text('🛡️ 常见病害诊断与救治')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F0B8D0' : '#B3587E')
                Text(this.species.troubleshooting)
                  .fontSize(12.5)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(19)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 底部一键收进花园
            Button(this.isInGarden ? '🪴 花园已有此花木 · 再次添置一盆' : '🪴 一键将此品种收进我的花园')
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
                this.addToGarden();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ left: 16, right: 16, top: 12 })
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
