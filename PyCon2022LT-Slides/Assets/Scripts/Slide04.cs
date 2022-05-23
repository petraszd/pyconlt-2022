using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slide04 : MonoBehaviour
{
  public Transform PixelsWrapper;
  public Transform PixelRay;
  public Transform RayFromCamera;
  public Transform RayFromSphere;

  private Animator animator;
  private const int MAX_STEP = 5;
  private int CurrentStep = 0;
  private Transform[] Pixels;
  private bool IsInCameraView = true;

  void Start()
  {
    animator = GetComponent<Animator>();

    Pixels = new Transform[PixelsWrapper.childCount];
    for (var i = 0; i < PixelsWrapper.childCount; ++i) {
      Pixels[i] = PixelsWrapper.GetChild(i);
    }
  }

  void Update()
  {
    if (Input.GetKeyDown(KeyCode.UpArrow)) {
      StepUp();
    } else if (Input.GetKeyDown(KeyCode.DownArrow)) {
      StepDown();
    }

    if (Input.GetKeyDown(KeyCode.A)) {
      if (IsInCameraView) {
        IsInCameraView = false;
        animator.SetTrigger("From");
      } else {
        IsInCameraView = true;
        animator.SetTrigger("To");
      }
    }
  }

  private void StepUp()
  {
    UpdateCurrentStep(+1);
  }

  private void StepDown()
  {
    UpdateCurrentStep(-1);
  }

  private void UpdateCurrentStep(int delta)
  {
    CurrentStep = Mathf.Clamp(CurrentStep + delta, 0, MAX_STEP);

    RayFromCamera.gameObject.SetActive(false);
    RayFromSphere.gameObject.SetActive(false);
    for (var i = 0; i < Pixels.Length; ++i) {
      Pixels[i].gameObject.SetActive(false);
    }

    if (CurrentStep >= 1) {
        RayFromCamera.gameObject.SetActive(true);
    }
    if (CurrentStep >= 2) {
        RayFromSphere.gameObject.SetActive(true);
    }
    if (CurrentStep >= 3) {
      PixelRay.gameObject.SetActive(true);
    }
    if (CurrentStep >= 4) {
        RayFromCamera.gameObject.SetActive(false);
        RayFromSphere.gameObject.SetActive(false);
    }
    if (CurrentStep == 5) {
      for (var i = 0; i < Pixels.Length; ++i) {
        Pixels[i].gameObject.SetActive(true);
      }
    }
  }
}
