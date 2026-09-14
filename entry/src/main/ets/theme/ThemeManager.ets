import { ColorScheme, LIGHT_THEME, DARK_THEME } from '../common/constants/ThemeConstants';
import { StorageService } from '../common/database/StorageService';

export class ThemeManager {
  private static instance: ThemeManager | null = null;
  private currentMode: string = 'light'; // 'system' | 'light' | 'dark'
  private isSystemDark: boolean = false;

  private constructor() {}

  public static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  public init(savedMode?: string): void {
    if (savedMode) {
      this.currentMode = savedMode;
    } else {
      this.currentMode = StorageService.getInstance().getThemeMode() || 'light';
    }
  }

  public setSystemDark(isDark: boolean): void {
    this.isSystemDark = isDark;
  }

  public getThemeMode(): string {
    return this.currentMode;
  }

  public setThemeMode(mode: string): void {
    this.currentMode = mode;
    StorageService.getInstance().setThemeMode(mode);
  }

  public isDark(): boolean {
    if (this.currentMode === 'dark') {
      return true;
    }
    if (this.currentMode === 'light') {
      return false;
    }
    return this.isSystemDark;
  }

  public getColors(): ColorScheme {
    return this.isDark() ? DARK_THEME : LIGHT_THEME;
  }
}
