/**
 * 养护成就徽章模型
 */
export interface BadgeModel {
  id: string;
  name: string;                // 徽章名称，如「甘霖初至」「七日坚守」「百卉芬芳」
  category: string;            // 分类：streak(坚守天数), plant(花园规模), care(养护频次), diary(日记心语), bloom(花开如愿)
  categoryName: string;        // 分类中文
  icon: string;                // 图标
  description: string;         // 达成描述
  target: number;              // 目标值
  current: number;             // 当前进度
  isUnlocked: boolean;         // 是否已解锁
  unlockedDate?: string;       // 解锁日期 YYYY-MM-DD
}
