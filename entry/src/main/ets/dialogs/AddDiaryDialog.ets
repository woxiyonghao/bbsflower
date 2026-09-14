import { DiaryModel } from '../common/models/DiaryModel';
import { PlantModel } from '../common/models/PlantModel';
import { DateUtil } from '../common/utils/DateUtil';

interface TagOption {
  key: string;
  name: string;
}

@Component
export struct AddDiaryDialog {
  @Prop isDark: boolean = false;
  @Prop plants: PlantModel[] = [];
  @Prop defaultPlantId: string = '';
  onSave?: (diary: DiaryModel) => void;
  onClose?: () => void;

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
    if (this.defaultPlantId.length > 0) {
      this.selectedPlantId = this.defaultPlantId;
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

    if (this.onSave) {
      this.onSave(diary);
    }
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

      Column() {
        // 头部
        Row() {
          Text('📖 记一笔绿意日记')
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
            // 1. 关联植物
            if (this.plants.length > 0) {
              Column({ space: 6 }) {
                Text('关联植物')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

                Scroll() {
                  Row({ space: 8 }) {
                    ForEach(this.plants, (plant: PlantModel) => {
                      Row({ space: 4 }) {
                        Text(plant.icon).fontSize(14)
                        Text(plant.nickname)
                          .fontSize(12)
                          .fontColor(this.selectedPlantId === plant.id ? '#FFFFFF' : (this.isDark ? '#DCD8EA' : '#2D2A3F'))
                      }
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .borderRadius(12)
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
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 2. 日记标题
            Column({ space: 6 }) {
              Text('日记标题')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextInput({ text: this.title, placeholder: '给这次新发现起个标题...' })
                .fontSize(13)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(10)
                .onChange((val: string) => {
                  this.title = val;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 3. 标签选择
            Column({ space: 6 }) {
              Text('成长阶段标签')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              Row({ space: 8 }) {
                ForEach(this.TAG_OPTIONS, (item: TagOption) => {
                  Text(item.name)
                    .fontSize(11)
                    .fontColor(this.selectedTag === item.key ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .borderRadius(10)
                    .backgroundColor(
                      this.selectedTag === item.key
                        ? (this.isDark ? '#A696D0' : '#8B7AB8')
                        : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
                    )
                    .onClick(() => {
                      this.selectedTag = item.key;
                    })
                })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 4. 心情符号
            Column({ space: 6 }) {
              Text('心情与印记')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              Row({ space: 10 }) {
                ForEach(this.MOOD_OPTIONS, (mood: string) => {
                  Text(mood)
                    .fontSize(20)
                    .padding(6)
                    .borderRadius(10)
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

            // 5. 日记正文
            Column({ space: 6 }) {
              Text('观察心得与时光手记')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDark ? '#A29DC0' : '#6B6780')

              TextArea({ text: this.content, placeholder: '记录叶片舒展、萌生新芽、光照与湿度的细微变化...' })
                .fontSize(13)
                .height(100)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                .borderRadius(10)
                .onChange((val: string) => {
                  this.content = val;
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
        }
        .constraintSize({ maxHeight: 380 })
        .scrollBar(BarState.Off)

        // 底部按钮
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

          Button('写下这抹绿意')
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
