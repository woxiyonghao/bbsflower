/**
 * 雅舍个人资料数据模型
 */
export interface UserProfileModel {
  avatar: string;
  nickname: string;
  bio: string;
}

export const DEFAULT_USER_PROFILE: UserProfileModel = {
  avatar: '🌸',
  nickname: '琉璃雅舍',
  bio: '一花一世界，一叶一菩提 · 单机绿意守护'
};

/**
 * 推荐预设头像列表（东方雅致花木绿植）
 */
export const PRESET_AVATARS: string[] = [
  '🌸', '🌷', '🌹', '🌻', '🌺', '🌼',
  '🍀', '🪴', '🌿', '🌱', '🎋', '🪷',
  '🌾', '🍃', '🌵', '🎍', '🍁', '✨'
];
