# Godot Project Settings Configuration

This document explains the project settings configured for Endless Waves.

## 🎮 Application Settings

### Basic Configuration
- **Name**: Endless Waves
- **Version**: 0.1.0-alpha
- **Main Scene**: `res://scenes/main/Main.tscn`
- **Features**: Mobile-optimized for Godot 4.4
- **Boot Splash**: Dark theme, no image for faster loading

### AutoLoad Singletons
```
GameManager    -> res://autoloads/GameManager.gd
EventBus       -> res://autoloads/EventBus.gd  
AudioManager   -> res://autoloads/AudioManager.gd
SaveManager    -> res://autoloads/SaveManager.gd
DataLoader     -> res://autoloads/DataLoader.gd
```

## 📱 Display Settings

### Mobile-Optimized Display
- **Resolution**: 1080x1920 (Portrait orientation)
- **Window Mode**: Fullscreen for mobile deployment
- **Stretch Mode**: Canvas items for consistent UI scaling
- **Stretch Aspect**: Expand to fill screen
- **Orientation**: Portrait locked

### Rendering
- **Renderer**: Mobile (GL Compatibility)
- **Texture Filter**: Linear for crisp mobile graphics
- **MSAA**: 2x for mobile performance balance
- **Pixel Snapping**: Enabled for crisp 2D graphics

## 🎯 Input Configuration

### Mobile Touch Controls
- **tap**: Primary touch interaction
- **long_press**: Context menus and detailed info
- **pause_game**: Escape key for desktop testing

### Touch Settings
- **Emulate Touch from Mouse**: Enabled for desktop testing
- **Emulate Mouse from Touch**: Enabled for hybrid input

## ⚙️ Physics Settings

### 2D Physics Configuration
- **Default Gravity**: Disabled (0, 0) - Top-down view
- **Separate Thread**: Enabled for better performance
- **Pause Aware Picking**: Enabled for UI responsiveness

### Physics Layers
1. **Player Units** - Defensive units
2. **Player Buildings** - Turrets, walls, structures  
3. **Enemies** - Enemy entities
4. **Projectiles** - Bullets, arrows, spells
5. **Environment** - Terrain, obstacles
6. **UI** - Interface elements
7. **Effects** - Visual effects, particles
8. **Sensors** - Detection areas, triggers

## 🛠️ Development Settings

### GDScript Warnings
- **Comprehensive Warnings**: All warnings enabled
- **Type Safety**: Unsafe operations flagged
- **Code Quality**: Unused variables, unreachable code detected
- **Performance**: Narrowing conversions flagged

### Debug Configuration
- **FPS Display**: Disabled by default
- **Verbose Output**: Disabled for cleaner logs
- **Error Handling**: Warnings as guidance, not errors

### Editor Enhancements
- **Folder Colors**: Visual organization
  - Red: autoloads/
  - Blue: components/
  - Green: data/
  - Yellow: scenes/
  - Purple: scripts/
- **Version Control**: Git plugin enabled

## 📦 Export Configuration

### Android Export
- **Target**: ARM64-v8a (modern Android devices)
- **Package**: com.yourstudio.endlesswaves
- **Permissions**: Internet, vibration, wake lock
- **Graphics**: OpenGL compatibility mode
- **Screen**: Immersive mode, all screen sizes supported

### iOS Export  
- **Target**: ARM64 (modern iOS devices)
- **Bundle ID**: com.yourstudio.endlesswaves
- **Export Method**: Debug/Release configurations
- **Capabilities**: Minimal permissions for privacy
- **Launch Screen**: Custom dark background

## 🎨 UI and Theming

### Interface Settings
- **Drop Mouse on GUI**: Disabled for touch optimization
- **Custom Theme**: res://assets/ui/theme.tres
- **Internationalization**: Ready for localization

### Asset Import
- **Blender/FBX**: Disabled (2D game)
- **WebP Compression**: Optimized for mobile
- **Canvas Texture Filter**: Linear for sharp UI

## ⚡ Performance Optimization

### Threading
- **Worker Pool**: 4 threads maximum
- **Physics Threading**: Separate thread enabled

### Memory Management
- **Occlusion Culling**: Enabled
- **Texture Compression**: Mobile-optimized
- **Asset Streaming**: Configured for mobile constraints

## 🔧 Development Workflow

### Testing Configuration
- **Desktop Testing**: Mouse emulates touch
- **Debug Builds**: Full warnings enabled
- **Performance Monitoring**: Built-in tools available

### Build Process
1. **Debug Builds**: Quick iteration with full debugging
2. **Release Builds**: Optimized for distribution
3. **Platform Testing**: Separate Android/iOS configurations

## 📋 Verification Checklist

Before building:
- [ ] AutoLoad scripts exist and are correctly configured
- [ ] Main scene path is valid
- [ ] Physics layers match game design
- [ ] Input actions are properly mapped
- [ ] Export presets are configured with signing
- [ ] Asset import settings are optimized
- [ ] Performance settings match target devices

## 🚀 Next Steps

1. **Create AutoLoad Scripts**: Implement the five singleton systems
2. **Build Main Scene**: Create the primary game scene structure
3. **Test Mobile Controls**: Verify touch input responsiveness
4. **Configure Signing**: Set up Android keystore and iOS certificates
5. **Optimize Assets**: Prepare textures and audio for mobile

The project is now configured following Godot best practices for mobile tower defense development!
