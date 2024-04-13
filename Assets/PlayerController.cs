using UnityEngine;

public class ThirdPersonCam : MonoBehaviour
{
    public float rotationSpeed;
    public float movementSpeed = 1f;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        float horizontalInput = Input.GetAxis("Horizontal") * movementSpeed * Time.deltaTime;
        float verticalInput = Input.GetAxis("Vertical") * movementSpeed * Time.deltaTime;

        Vector3 inputDirection = new Vector3(horizontalInput, 0, verticalInput);
        transform.Translate(inputDirection);
    }

}
