# FAQ

## I'm getting `Input/output error`, `Invalid argument`, `No space left on device` errors in the `Creating ramdisk` step. What does this mean?

This is most likely caused by errors earlier in the build process. Look further up in the logs to get some hints about what step is failing. This can also be caused by not having enough space, see [issue #7](https://github.com/reinterpretcat/lfs/issues/7) for more details.

## Linux Kernel Won't Build

This problem could possibily be caused when the `kernel.config` was outdated for the version of Linux Kernel that LFS is using. See https://github.com/reinterpretcat/lfs/issues/7#issuecomment-570835585 for more about what the logs tend to look like with this issue.

## My question is not listed here. What should I do?

Sometimes open and closed GitHub issues have a lot of good debugging steps. Checking those is a good place to start. Searching on Google or through the LFS book is also a good step to help debug. If you still can't find your answer submit an issue on this GitHub repo.
