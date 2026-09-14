import router from '@ohos.router';
import { DiaryModel } from '../common/models/DiaryModel';
import { PlantModel } from '../common/models/PlantModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { DateUtil } from '../common/utils/DateUtil';
import { PlantIcon } from '../common/components/PlantIcon';
import { GlassCard } from '../common/components/GlassCard';

interface AddDiaryPageParams {
  defaultPlantId?: string;
}

interface TagOption {
  key: string;
  name: string;
}

@Entry
@Component
struct AddDiaryPage {
  @State isDark: boolean = false;
  @State plants: PlantModel[] = [];
  @State selectedPlantId: string = '';
  @State title: string = '';
  @State content: string = '';
  @State selectedTag: string = 'observe';
  @State selectedMood: string = '🌱';

  private readonly TAG_OPTIONS: TagOption[] = [
    { key: 'observe', name: '日常观察' },
    { key: 'sprout', name: '萌发新芽' },
    { key: 'bloom', name: '花开如愿' },
    { key: 'repot', name: '翻盆换土' },
    { key: 'pest', name: '病虫害' }
  ];

  private readonly MOOD_OPTIONS: string[] = ['🌱', '🌸', '💧', '☀️', '🥰', '🌿', '✂️'];

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.plants = StorageService.getInstance().getPlants();

    const params = router.getParams() as AddDiaryPageParams;
    if (params && params.defaultPlantId) {
      this.selectedPlantId = params.defaultPlantId;
    } else if (this.plants.length > 0) {
      this.selectedPlantId = this.plants[0].id;
    }
  }

  private submit(): void {
    if (this.title.trim().length === 0) {
      return;
    }

    const currentPlant = this.plants.find(p => p.id === this.selectedPlantId);
    const tagObj = this.TAG_OPTIONS.find(t => t.key === this.selectedTag);

    const diary: DiaryModel = {
      id: `dry_${Date.now()}`,
      plantId: this.selectedPlantId,
      plantName: currentPlant ? currentPlant.nickname : '花园随笔',
      title: this.title,
      content: this.content,
      date: DateUtil.formatDate(),
      time: DateUtil.formatTime(),
      tag: this.selectedTag,
      tagName: tagObj ? tagObj.name : '日常观察',
      mood: this.selectedMood
    };

    StorageService.getInstance().addDiary(diary);
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

        Text('记篇成长日记')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        Button('写好了')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
          .borderRadius(14)
          .height(32)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            this.submit();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      Scroll() {
        Column({ space: 16 }) {
          // 1. 关联植物选择
          if (this.plants.length > 0) {
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
              Column({ space: 10 }) {
                Text('关联花园花草')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Scroll() {
                  Row({ space: 10 }) {
                    ForEach(this.plants, (plant: PlantModel) => {
                      Row({ space: 6 }) {
                        PlantIcon({ plantName: plant.name, sizeVal: 32, isDark: this.isDark, showSubBadge: false })
                        Text(plant.nickname)
                          .fontSize(12)
                          .fontWeight(this.selectedPlantId === plant.id ? FontWeight.Bold : FontWeight.Normal)
                          .fontColor(this.selectedPlantId === plant.id ? '#FFFFFF' : (this.isDark ? '#DCD8EA' : '#2D2A3F'))
                      }
                      .padding({ left: 10, right: 12, top: 6, bottom: 6 })
                      .borderRadius(14)
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
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }

          // 2. 标题与分类
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 14 }) {
              Column({ space: 6 }) {
                Text('日记标题')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                TextInput({ text: this.title, placeholder: '记录一次令你欢喜的小变化...' })
                  .fontSize(14)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .borderRadius(12)
                  .onChange((val: string) => {
                    this.title = val;
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              Column({ space: 6 }) {
                Text('成长阶段标签')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Row({ space: 8 }) {
                  ForEach(this.TAG_OPTIONS, (item: TagOption) => {
                    Button(item.name)
                      .fontSize(11)
                      .fontColor(this.selectedTag === item.key ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
                      .backgroundColor(
                        this.selectedTag === item.key
                          ? (this.isDark ? '#A696D0' : '#8B7AB8')
                          : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                      )
                      .borderRadius(10)
                      .height(30)
                      .onClick(() => {
                        this.selectedTag = item.key;
                      })
                  })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')

              Column({ space: 6 }) {
                Text('今日心情')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Row({ space: 10 }) {
                  ForEach(this.MOOD_OPTIONS, (mood: string) => {
                    Text(mood)
                      .fontSize(22)
                      .padding(8)
                      .borderRadius(12)
                      .backgroundColor(
                        this.selectedMood === mood
                          ? (this.isDark ? 'rgba(212, 184, 126, 0.25)' : 'rgba(201, 169, 110, 0.25)')
                          : 'transparent'
                      )
                      .onClick(() => {
                        this.selectedMood = mood;
                      })
                  })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
            .width('100%')
          }

          // 3. 正文记录
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
            Column({ space: 6 }) {
              Text('观察心得与时光手记')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextArea({ text: this.content, placeholder: '记录叶片舒展、萌生新芽、光照与湿度的细微变化...' })
                .fontSize(13.5)
                .height(180)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(12)
                .onChange((val: string) => {
                  this.content = val;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 底部写好了按钮
          Button('写下这抹绿意')
            .width('100%')
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
            .borderRadius(16)
            .margin({ top: 8, bottom: 24 })
            .onClick(() => {
              this.submit();
            })
        }
        .padding({ left: 16, right: 16, top: 12 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#100D1C' : '#FAF6F0')
  }
}
