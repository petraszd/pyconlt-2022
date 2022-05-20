using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlideShow : MonoBehaviour
{
  public Canvas[] Slides;
  private Transform CurrentSlide = null;
  private int CurrentIndex = 0;

  void Start()
  {
    UpdateCurrentIndex(0);
  }

  void Update()
  {
    if (IsAskForNextSlide()) {
      NextSlide();
    } else if (IsAskForPrevSlide()) {
      PrevSlide();
    }
  }

  private bool IsAskForNextSlide()
  {
    return (
        Input.GetKeyDown(KeyCode.Space) ||
        Input.GetKeyDown(KeyCode.RightArrow)
        );
  }

  private bool IsAskForPrevSlide()
  {
    return Input.GetKeyDown(KeyCode.LeftArrow);
  }

  private void NextSlide()
  {
    UpdateCurrentIndex(+1);
  }

  private void PrevSlide()
  {
    UpdateCurrentIndex(-1);
  }

  private void UpdateCurrentIndex(int delta)
  {
    CurrentIndex += delta;
    if (CurrentIndex < 0) {
      CurrentIndex = 0;
    } else if (CurrentIndex >= Slides.Length) {
      CurrentIndex = Slides.Length - 1;
    }

    Debug.LogFormat("Next Index = {0}", CurrentIndex);

    if (CurrentSlide != null) {
      Destroy(CurrentSlide.gameObject);
    }
    CurrentSlide = (Instantiate(Slides[CurrentIndex]) as Canvas).transform;
    CurrentSlide.SetParent(transform);
  }
}
