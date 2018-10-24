Take home exercise:

Simple iOS GIF search app.

Description:

 - [x] Lets users search for GIFs using Giphy API.
 - [x] App has: text input for search, search button & collection view for displaying search results.
 - [x] Giphy API docs here: https://developers.giphy.com/. You'll probably only need single endpoint: /v1/gifs/search.  You can use our API key: ZsUpUm2L6cVbvei347EQNp7HrROjbOdc
 - [x] One option for rendering GIFs is https://github.com/ibireme/YYImage.  Feel free to use an alternative.

Details

 - [x] Gifs don't need to be interactive.
   - [x] Extra Credit: tapping GIF does one of the following: save to camera roll/copy/show sharing option/show fullscreen.
 - [x] Only show single page of 100 results.
   - [ ] Extra Credit: show more using paging.
 - [x] Collection view layout can be simple - single GIF per row, with correct aspect ratio.
   - [x] Extra Credit: A better layout.
 - [x] Scrolling through collection view/GIFs should be smooth.  
 - [x] GIFs should appear as they load.
   - [ ] Extra credit: unload offscreen GIFs.
 - [x] Update search results when when user taps search button.
   - [x] Extra Credit: update search results as user edit search text.
 - [x] App layout should adapt to any iOS phone.
   - [x] Extra credit: support landscape & portrait orientations or iPad.

Feel free to use any third party libraries to complete task.


Future Improvements:
 - **Better performance on poor network connections:** The app currently does not attempt to detect and respond to poor network connections. While the app uses Giphy's `fixedWidth` image size in the search results collection view, it could be possible to detect slow loading of image assets and choose another smaller representation to trade image quality for faster load times. Reducing the number of GIFs returned in the initial search call and then paginating for more results might also reduce search times on a slow network.
 - **MP4 assets:** Animated .gif files tend to be very large, and Giphy offers .mp4 assets which display the same animation in a significantly smaller file size. I experimented with using AVFoundation to load and display these video assets, but found that using an `AVPlayerLooper` to loop a video inside of a reusable collection view cell resulted in odd rendering glitches. With further exploration, the use of video assets might be a viable way to reduce the size of assets loaded over the network.
 - **Improved queueing and caching of images:** I used the `YYWebImage` framework to handle loading, caching, and displaying animated GIFs. While the default functionality provided by the framework is incredibly convenient for getting image loading working quickly, it does not necessarily have the most optimized behavior for queuing the loading of images from the network to prioritize visible cells. The default caching behavior could also be further optimized to more aggressively discard images from the cache when they are no longer needed. 
 - **Better error handling in the UI:** While the app will display error messages if the search API call fails, there are several other places (such as loading images) where failure is silently ignored. The app should more gracefully handle all failure cases in a way that is understandable (and ideally recoverable) by the user.
 - **GIF attribution:** The Giphy API terms of service require that "all apps that use the GIPHY API [must] conspicuously display "Powered By GIPHY" attribution marks where the API is utilized." Visible attribution would need to be added before requesting a production API key from Giphy.
 - **Improved Giphy API wrapper:** The Giphy iOS SDK is very useful for quickly implementing search functionality, but it has room for improvement. In particular, failed API calls can return somewhat opaque error messages, and some of the SDK's documentation (especially around pagination data) is ambiguous or incorrect.



Known issues:
 - If the detail view is presented when the device is in portrait orientation, and then dismissed when the device is in landscape orientation (or vice versa), then the collection view layout may display with an incorrect number of columns. The source of this bug is when `prepare()` is called on the masonry layout when the collection view is about to re-appear. At this point, the collection view's `bounds` have been updated to reflect the new orientation, but the `layoutMargins` still reflect the margin values for the previous orientation. This seems to be a UIKit bug, which could possibly be worked around by manually invalidating the layout at the point when the `layoutMargins` are updated correctly.
