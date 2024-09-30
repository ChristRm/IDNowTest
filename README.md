# Technical Test IDNow - iOS Camera & Image Preview Application

## Overview
This project is an iOS application that allows users to capture an image using their device's camera, retrieve data from a JSON API, and display a preview of the captured image along with descriptive information from the API. The application follows the given requirements and aims to provide a simple yet effective demonstration of good software development practices, adhering to clean coding principles and a modular architecture.

## Architecture & Technical Decisions
- **Architecture**: The application is mix of using the **MVVM (Model-View-ViewModel)** pattern and **MVC (Model-View-Controller)** pattern. **MVVM** was chosen for its clear separation of concerns, making the UI logic and business logic independent and easier to maintain. In addition **MVVM** provides the great way to test the logic of the particular screen.
- **Networking**: The networking layer is implemented using `URLSession` to make requests to the external API.
- **Combine Framework**: To manage asynchronous events, data bindings, and API responses, I used **Combine**, providing a reactive approach to state and data handling. Having reactive bindings is very practical when using MVVM pattern.
- **Camera Integration**: The `CameraService` component handles capturing images using `AVFoundation`. This keeps the view controller focused only on managing the UI.
- **Data Binding**: The view model is responsible for fetching data and updating the view. This design promotes testability and helps maintain a clear separation between business logic and UI.
- **UI Design**: The main screen is constructed in the Main.storyboard just for simplicity as it's a default XCode implementation when you create the project. The Image scren is constructed using with an `.xib` file. This is a better approach to avoid conflicts in .storyboard files, but also having the dedicated `.xib` file for each screen is more practical, takes less time to load and makes the UI construction easier to find.

## Technical Choices & Best Practices
- **SOLID Principles**: Applied throughout the code to ensure better maintainability and extensibility. For example:
  - **Single Responsibility**: The `CameraService` is solely responsible for handling camera interactions.
  - **Dependency Inversion**: ImageViewModel depend on abstracted services, making it easy to mock or substitute during testing. The CameraViewController depends on `CameraService`, which is abstract type and can be injected from outside.
- **DRY (Don't Repeat Yourself)**: Code reuse is emphasized across view models and services, avoiding duplication.
- **KISS (Keep It Simple, Stupid)**: The application is kept as simple as possible to achieve the required functionality without unnecessary complexity. For instance, there is no need to have ViewModel for the camera screen, it is too simple. It's logic is purely of UI kind, streaming of the camera image and capturing the image.
There is no implementation of any sort of Router or Coordinator, as there just 2 screen, this would be and overkill.

## Testing
- **Unit Tests**: `ImageViewModel` is covered with unit tests to verify their behavior.
- **Mocking**: The `MockURLProtocol` is used for testing network requests, ensuring consistent and controlled responses.

## If Given More Time
- **Better UI/UX**: Currently, the UI/UX is as simple as possible, with more time I would think about better way to display the information in the Image screen. I would improve UI of the both Camera and Image screens.
- **More Robust Error Handling**: Currently, the error handling is minimal, mainly focused on user notifications for API errors and camera access issues. With more time, I would add finer-grained error handling and user-friendly messages for edge cases.
- **Code Coverage Expansion**: I would cover the CameraService with tests.

## Task Breakdown
In a real work environment, I would break the task into smaller, reviewable sub-tasks as follows:
1. **Setup Project Structure and Dependencies**: Create a project, set up folders, and add necessary dependencies.
2. **Implement Camera Capture**: Develop the camera capture feature, ensuring the user can take pictures.
3. **API Integration**: Set up the network layer and integrate with the Dummy JSON API.
4. **Camera screen implementation**: Create the `.xib` file for the UI, ensuring all required elements are present.
5. **Image Preview with Data**: Combine camera functionality and API data to display the preview.
6. **Download Image Feature**: Implement functionality to save the captured image to the device.
7. **Testing**: Write unit tests for the view models and camera service.

## Time Spent
The entire challenge was completed in approximately **6 hours**, which included:
- **Development**: 4.5 hours
- **Testing**: 1 hour
- **Documentation and Final Review**: 0.5 hours

## Conclusion
This project demonstrates a simple yet structured approach to solving the given problem using modern iOS development techniques. The architectural decisions aim for maintainability, testability and simplicity.
