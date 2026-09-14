import { SpeciesModel } from '../common/models/SpeciesModel';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';
import { EmptyState } from '../common/components/EmptyState';

@Component
export struct WikiTab {
  @Prop isDark: boolean = false;
  @Prop speciesList: SpeciesModel[] = [];

  onSelectSpecies?: (species: SpeciesModel) => void;
  onQuickAddToGarden?: (species: SpeciesModel) => void;

  @State searchText: string = '';
  @State selectedCategory: string = 'all'; // all, foliage, flower, succulent, orchid, bulb
  @State selectedDifficulty: string = 'all'; // all, easy, medium, hard

  private getFilteredSpecies(): SpeciesModel[] {
    return this.speciesList.filter(sp => {
      // 1. 搜索关键词
      if (this.searchText.trim().length > 0) {
        const query = this.searchText.trim().toLowerCase();
        const matchName = sp.name.toLowerCase().indexOf(query) !== -1;
        const matchLatin = sp.latinName.toLowerCase().indexOf(query) !== -1;
        const matchAlias = sp.alias.toLowerCase().indexOf(query) !== -1;
        const matchDesc = sp.description.toLowerCase().indexOf(query) !== -1;
        const matchLanguage = sp.flowerLanguage.toLowerCase().indexOf(query) !== -1;
        if (!matchName && !matchLatin && !matchAlias && !matchDesc && !matchLanguage) {
          return false;
        }
      }

      // 2. 分类筛选
      if (this.selectedCategory !== 'all' && sp.category !== this.selectedCategory) {
        return false;
      }

      // 3. 难度筛选
      if (this.selectedDifficulty !== 'all' && sp.difficulty !== this.selectedDifficulty) {
        return false;
      }

      return true;
    });
  }

  build() {
    Column() {
      // 1. 顶部 Header
      Row() {
        Column({ space: 2 }) {
          Text('百花图鉴')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
          Text(`预置 ${this.speciesList.length} 种名花养护宝典 · 离线随时查阅`)
            .fontSize(12)
            .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 2. 搜索框
      Search({ value: this.searchText, placeholder: '搜花名、学名、别名或花语...' })
        .height(38)
        .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.05)')
        .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
        .placeholderColor(this.isDark ? '#736F90' : '#8E8AA3')
        .margin({ left: 16, right: 16, bottom: 8 })
        .onChange((val: string) => {
          this.searchText = val;
        })

      // 3. 分类胶囊栏
      Scroll() {
        Row({ space: 8 }) {
          Button('全部')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'all' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.selectedCategory === 'all' ? (this.isDark ? '#B8985E' : '#C9A96E') : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.selectedCategory = 'all'; })

          Button('🌿 观叶植物')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'foliage' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.selectedCategory === 'foliage' ? '#388E6D' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.selectedCategory = 'foliage'; })

          Button('🌸 观花花卉')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'flower' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.selectedCategory === 'flower' ? '#B3587E' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.selectedCategory = 'flower'; })

          Button('💎 多肉多浆')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'succulent' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.selectedCategory === 'succulent' ? '#8B7AB8' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.selectedCategory = 'succulent'; })

          Button('🦋 兰科名卉')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'orchid' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.selectedCategory === 'orchid' ? '#7862B0' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.selectedCategory = 'orchid'; })

          Button('🧅 球根花卉')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'bulb' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
            .backgroundColor(this.selectedCategory === 'bulb' ? '#B8823B' : (this.isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)'))
            .borderRadius(14)
            .height(30)
            .onClick(() => { this.selectedCategory = 'bulb'; })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // 4. 百科卡片列表
      if (this.getFilteredSpecies().length === 0) {
        EmptyState({
          icon: '🔍',
          title: '未找到相关花种',
          desc: '试着缩短搜索词，或切换分类筛选查看更多品种。',
          buttonText: '清除搜索条件',
          isDark: this.isDark,
          onButtonClick: () => {
            this.searchText = '';
            this.selectedCategory = 'all';
            this.selectedDifficulty = 'all';
          }
        })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.getFilteredSpecies(), (sp: SpeciesModel) => {
              GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
                Row({ space: 12 }) {
                  // 图标
                  Text(sp.icon)
                    .fontSize(34)
                    .padding(10)
                    .borderRadius(18)
                    .backgroundColor(this.isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.03)')

                  // 信息
                  Column({ space: 4 }) {
                    Row({ space: 6 }) {
                      Text(sp.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                      StatBadge({
                        text: sp.difficultyName,
                        colorScheme: sp.difficulty === 'easy' ? 'green' : (sp.difficulty === 'medium' ? 'gold' : 'petal'),
                        isDark: this.isDark
                      })
                    }

                    Text(`${sp.latinName} · ${sp.family}`)
                      .fontSize(11)
                      .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                    Text(`花语：「${sp.flowerLanguage}」`)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#E8A0BF' : '#B3587E')

                    Row({ space: 6 }) {
                      StatBadge({
                        text: `浇水约${sp.suggestWaterDays}天`,
                        icon: '💧',
                        colorScheme: 'blue',
                        isDark: this.isDark
                      })
                      StatBadge({
                        text: sp.categoryName,
                        icon: '🏷️',
                        colorScheme: 'violet',
                        isDark: this.isDark
                      })
                    }
                    .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  // 一键加入花园
                  Column({ space: 6 }) {
                    Button('＋ 入园')
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
                      .borderRadius(10)
                      .height(28)
                      .padding({ left: 10, right: 10 })
                      .onClick(() => {
                        if (this.onQuickAddToGarden) {
                          this.onQuickAddToGarden(sp);
                        }
                      })

                    Text('要点 ❯')
                      .fontSize(11)
                      .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
                .onClick(() => {
                  if (this.onSelectSpecies) {
                    this.onSelectSpecies(sp);
                  }
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
