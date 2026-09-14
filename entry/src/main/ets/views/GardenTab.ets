import router from '@ohos.router';
import { PlantModel } from '../common/models/PlantModel';
import { DateUtil } from '../common/utils/DateUtil';
import { CareScheduler } from '../common/utils/CareScheduler';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';
import { EmptyState } from '../common/components/EmptyState';

@Component
export struct GardenTab {
  @Prop isDark: boolean = false;
  @Prop plants: PlantModel[] = [];

  onSelectPlant?: (plant: PlantModel) => void;
  onOpenAddPlant?: () => void;
  onQuickWater?: (plant: PlantModel) => void;

  @State currentFilter: string = 'all'; // all, due_water, balcony, living_room, favorite

  private getFilteredPlants(): PlantModel[] {
    const today = DateUtil.formatDate();
    return this.plants.filter(plant => {
      if (this.currentFilter === 'due_water') {
        const nextWater = CareScheduler.getNextWaterDate(plant);
        return DateUtil.diffDays(nextWater, today) <= 0;
      }
      if (this.currentFilter === 'balcony') {
        return plant.location.indexOf('阳台') !== -1;
      }
      if (this.currentFilter === 'living_room') {
        return plant.location.indexOf('客厅') !== -1;
      }
      if (this.currentFilter === 'favorite') {
        return plant.isFavorite;
      }
      return true;
    });
  }

  build() {
    Column() {
      // 1. 顶部 Header
      Row() {
        Column({ space: 2 }) {
          Text('我的花园')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
          Text(`共收录 ${this.plants.length} 株花草档案 · 芳菲自赏`)
            .fontSize(12)
            .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button('＋ 添置新绿')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
          .borderRadius(16)
          .height(36)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddPlantPage' });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 2. 筛选胶囊栏
      Scroll() {
        Row({ space: 8 }) {
          Button('全部植物')
            .fontSize(12)
            .fontColor(this.currentFilter === 'all' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.currentFilter === 'all' ? (this.isDark ? '#B8985E' : '#C9A96E') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.currentFilter = 'all'; })

          Button('💧 待浇水')
            .fontSize(12)
            .fontColor(this.currentFilter === 'due_water' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.currentFilter === 'due_water' ? '#3577B8' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.currentFilter = 'due_water'; })

          Button('📍 阳台区')
            .fontSize(12)
            .fontColor(this.currentFilter === 'balcony' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.currentFilter === 'balcony' ? (this.isDark ? '#7862B0' : '#8B7AB8') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.currentFilter = 'balcony'; })

          Button('🛋️ 客厅区')
            .fontSize(12)
            .fontColor(this.currentFilter === 'living_room' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.currentFilter === 'living_room' ? (this.isDark ? '#7862B0' : '#8B7AB8') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.currentFilter = 'living_room'; })

          Button('⭐ 收藏置顶')
            .fontSize(12)
            .fontColor(this.currentFilter === 'favorite' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.currentFilter === 'favorite' ? '#B8823B' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.currentFilter = 'favorite'; })
        }
        .padding({ left: 16, right: 16, top: 4, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // 3. 花盆列表
      if (this.getFilteredPlants().length === 0) {
        EmptyState({
          icon: '🪴',
          title: '暂无匹配的花草档案',
          desc: '快去添置你的第一株绿意，或切换筛选标签查看吧。',
          buttonText: '＋ 添置新绿',
          isDark: this.isDark,
          onButtonClick: () => {
            if (this.onOpenAddPlant) {
              this.onOpenAddPlant();
            }
          }
        })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.getFilteredPlants(), (plant: PlantModel) => {
              GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
                Row({ space: 14 }) {
                  // 大图标
                  PlantIcon({ plantName: plant.name, sizeVal: 48, isDark: this.isDark })

                  // 植物详情
                  Column({ space: 4 }) {
                    Row({ space: 6 }) {
                      Text(plant.nickname)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                      if (plant.isFavorite) {
                        Text('⭐')
                          .fontSize(11)
                      }
                    }

                    Text(`${plant.name} · ${plant.location}`)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                    Row({ space: 6 }) {
                      StatBadge({
                        text: DateUtil.getRemainingDaysDesc(CareScheduler.getNextWaterDate(plant), DateUtil.formatDate()),
                        icon: '💧',
                        colorScheme: DateUtil.diffDays(CareScheduler.getNextWaterDate(plant), DateUtil.formatDate()) <= 0 ? 'petal' : 'blue',
                        isDark: this.isDark
                      })

                      StatBadge({
                        text: plant.potSize,
                        icon: '🪴',
                        colorScheme: 'violet',
                        isDark: this.isDark
                      })
                    }
                    .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  // 快捷操作
                  Column({ space: 6 }) {
                    Button('浇水')
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.isDark ? '#305480' : '#3A7EC2')
                      .borderRadius(10)
                      .height(28)
                      .padding({ left: 10, right: 10 })
                      .onClick(() => {
                        if (this.onQuickWater) {
                          this.onQuickWater(plant);
                        }
                      })

                    Text('档案 ❯')
                      .fontSize(11)
                      .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/PlantDetailPage',
                    params: { plantId: plant.id }
                  });
                })
              }
            })
          }
          .padding({ left: 16, right: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }
}
