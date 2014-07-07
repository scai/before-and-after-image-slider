import 'dart:html';
import 'dart:math';
import 'dart:async';

void main() {
  BeforeAndAfterPictureFrame frame = new BeforeAndAfterPictureFrame();
  new Future.delayed(const Duration(seconds: 1), () => frame.demoAnimation());
  document.querySelector('#replay').onClick.listen((e) => frame.demoAnimation());
}

class BeforeAndAfterPictureFrame {
  static const int IMAGE_WIDTH = 500;
  static const int IMAGE_HEIGHT = 300;
  static const int SLIDER_WIDTH = 6;
  static const String ANIMATION = 'animated-left';
  
  bool isDragging = false;
  bool isDemoInProgress = false;
  Element slider;
  Element imageAfter;
  Element timeTravelPhoto;
  
  BeforeAndAfterPictureFrame({int x:0}) {
    imageAfter = document.querySelector('#image-after');
    slider = document.querySelector('#slider')
        ..style.width = '${SLIDER_WIDTH}px'
        ..onMouseDown.listen((e) => isDragging = true);
    timeTravelPhoto = document.querySelector('#photo-frame')
        ..onMouseMove.listen(onSliderMouseMoved)
        ..onMouseUp.listen((e) => isDragging = false)
        ..onClick.listen((e) => slideTo(x:getRelativeX(e)));
    setSliderX(x);
  }
  
  void onSliderMouseMoved(MouseEvent event) {
    if (isDragging && event.button == 0) {
      int sliderX = getRelativeX(event);
      setSliderX(sliderX);
      event.preventDefault();
      event.stopPropagation();
    }
  }
  
  /**
   * Returns the pointer's X position relative to the photo container.
   */
  int getRelativeX(MouseEvent event) {
    return max(0, min(IMAGE_WIDTH - SLIDER_WIDTH,
        event.client.x - timeTravelPhoto.offsetLeft - SLIDER_WIDTH ~/ 2));
  }
  
  /**
   * Sets the slider position without CSS animation. This is used in dragging.
   */
  void setSliderX(int x) {
    slider.style.left = '${x}px';
    imageAfter.style.left = '${x}px';
  }
  
  /**
   * Moves the slider to a position after a delay. The returned Future will be 
   * completed after the animation is finished. Do not use this for dragging,
   * because performance suffers.
   */
  Future slideTo({int x:0, int delayMs:0}) {
    [slider, imageAfter].forEach((Element element) {
        element.classes.add(ANIMATION);
        element.style
            ..left = '${x}.px'
            ..transitionDelay = '${delayMs}ms';
    });
    
    // Remove transition animation after click-to-slide, because the
    // animation doesn't work well with dragging.
    return new Future.delayed(new Duration(milliseconds:delayMs + 1000), () {
      [slider, imageAfter].forEach((Element element) {
          element.classes.remove(ANIMATION);
          element.style.transitionDelay = '';
      });
    });
  }
  
  /**
   * Shows a demo animation with the slider boucing back and forth.
   */
  void demoAnimation() {
    if (isDemoInProgress) return;
    const int animationDelayMs = 800;
    isDemoInProgress = true;
    slideTo(x:BeforeAndAfterPictureFrame.IMAGE_WIDTH, delayMs:800).then((result) =>
      slideTo(x:0, delayMs:800).then((result) {
        slideTo(x:BeforeAndAfterPictureFrame.IMAGE_WIDTH ~/ 3, delayMs:800).then((result) =>
          isDemoInProgress = false);
      })
    );
  }
}
