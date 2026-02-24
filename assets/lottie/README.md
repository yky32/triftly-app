# Lottie Animation Files

Place your Lottie animation JSON files in this directory.

## Default Splash Animation

The splash screen expects a file named `splash.json` by default.

## How to Add a Lottie File

1. Download or create a Lottie animation file (`.json` format)
2. Place it in this directory (`assets/lottie/`)
3. Update the `lottiePath` parameter in `SplashScreen` if using a different filename

## Where to Get Lottie Files

- [LottieFiles](https://lottiefiles.com/) - Free and premium Lottie animations
- [LottieFiles GitHub](https://github.com/LottieFiles/lottie-android) - Open source animations

## Example

If you have a file named `my-animation.json`, you can use it like this:

```dart
SplashScreen(
  lottiePath: 'assets/lottie/my-animation.json',
)
```

