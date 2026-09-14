/**
 * 琉璃花语 - 主题视觉设计常量与液态玻璃色彩体系
 */

export interface ColorScheme {
  gold: string;
  goldDeep: string;
  goldLight: string;
  violet: string;
  violetDeep: string;
  petal: string;
  leaf: string;
  mint: string;
  
  bgStart: string;
  bgMiddle: string;
  bgEnd: string;

  glassBg: string;
  glassBgStrong: string;
  glassBorder: string;
  glassHighlight: string;
  
  cardBg: string;
  dialogBg: string;

  textHeading: string;
  textMain: string;
  textMuted: string;
  textSoft: string;

  inputBg: string;
  divider: string;
  shadowColor: string;
}

export const LIGHT_THEME: ColorScheme = {
  gold: '#C9A96E',
  goldDeep: '#A8874A',
  goldLight: '#FDF4E5',
  violet: '#8B7AB8',
  violetDeep: '#5E4A8C',
  petal: '#E8A0BF',
  leaf: '#5BA88A',
  mint: '#7BC4A8',

  bgStart: '#FBF7F2',
  bgMiddle: '#F5F0FA',
  bgEnd: '#FDF9F3',

  glassBg: 'rgba(255, 255, 255, 0.72)',
  glassBgStrong: 'rgba(255, 255, 255, 0.88)',
  glassBorder: 'rgba(255, 255, 255, 0.90)',
  glassHighlight: 'rgba(255, 255, 255, 0.60)',

  cardBg: '#FFFFFF',
  dialogBg: '#FDFBFA',

  textHeading: '#1F1B33',
  textMain: '#2D2A3F',
  textMuted: '#6B6780',
  textSoft: '#8E8AA3',

  inputBg: 'rgba(245, 240, 235, 0.85)',
  divider: 'rgba(200, 190, 210, 0.35)',
  shadowColor: 'rgba(90, 70, 140, 0.12)'
};

export const DARK_THEME: ColorScheme = {
  gold: '#D4B87E',
  goldDeep: '#B8985E',
  goldLight: '#2C2314',
  violet: '#A696D0',
  violetDeep: '#7862B0',
  petal: '#E8A0BF',
  leaf: '#6BC4A0',
  mint: '#8AD4B8',

  bgStart: '#0F0D1A',
  bgMiddle: '#161125',
  bgEnd: '#1A1430',

  glassBg: 'rgba(35, 28, 52, 0.75)',
  glassBgStrong: 'rgba(48, 38, 70, 0.88)',
  glassBorder: 'rgba(255, 255, 255, 0.14)',
  glassHighlight: 'rgba(255, 255, 255, 0.10)',

  cardBg: '#1D172E',
  dialogBg: '#1B152B',

  textHeading: '#F2EFF9',
  textMain: '#DCD8EA',
  textMuted: '#A29DC0',
  textSoft: '#736F90',

  inputBg: 'rgba(30, 24, 45, 0.90)',
  divider: 'rgba(255, 255, 255, 0.10)',
  shadowColor: 'rgba(0, 0, 0, 0.55)'
};
