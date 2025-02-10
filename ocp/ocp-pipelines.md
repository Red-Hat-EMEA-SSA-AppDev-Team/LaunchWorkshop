Tekton

*   tasks, clustertasks
*   pipelines
*   taskrun, pipelineruns
*   workspaces
*   triggers, trigger template and event listeners

Permission

*   system:serviceaccount:cargo-pipeline:pipeline
*   pipeline-scc
    *   example: s2i community task => "priviledge"

Pipelining

*   Build once, deploy everywhere
*   Inner and Outer loops
    *   Multiple pipeline (push - tag - release)
*   Principle of promoting containers (versioning and immutability…)
    *   it's highly recommended to avoid the use of the ‘latest’ tag.  The best practice is to give the image and exact naming that will guarantee its immutability.  This name can be anything.  Sometimes it's the commit name, sometimes it's a plain version.  The best practice is for it to be aligned with a commit tag.