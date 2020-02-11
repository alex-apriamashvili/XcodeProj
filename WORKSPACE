load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# ================================================================
# Skylib dependency. bazel v1.0.0 ✔︎
# ================================================================

skylib_commit = "e59b620b392a8ebbcf25879fc3fde52b4dc77535"

skylib_shallow = "1570639401 -0400"

git_repository(
    name = "bazel_skylib",
    commit = skylib_commit,
    remote = "https://github.com/bazelbuild/bazel-skylib.git",
    shallow_since = skylib_shallow,
)

load(
    "@bazel_skylib//:workspace.bzl",
    "bazel_skylib_workspace",
)

bazel_skylib_workspace()

# ================================================================
# Swift support requires rules_swift, apple_support. bazel v1.0.0 ✔︎
# ================================================================

rules_swift_commit = "ebef63d4fd639785e995b9a2b20622ece100286a"

rules_swift_shallow = "1570649187 -0700"

apple_support_commit = "8c585c66c29b9d528e5fcf78da8057a6f3a4f001"

apple_support_shallow = "1570646613 -0700"

git_repository(
    name = "build_bazel_rules_swift",
    commit = rules_swift_commit,
    remote = "https://github.com/bazelbuild/rules_swift.git",
    shallow_since = rules_swift_shallow,
)

git_repository(
    name = "build_bazel_apple_support",
    commit = apple_support_commit,
    remote = "https://github.com/bazelbuild/apple_support.git",
    shallow_since = apple_support_shallow,
)

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

# ================================================================
# Protobuf dependencies. bazel v1.0.0 ✔︎
# ================================================================

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_proto",
    sha256 = "602e7161d9195e50246177e7c55b2f39950a9cf7366f74ed5f22fd45750cd208",
    strip_prefix = "rules_proto-97d8af4dc474595af3900dd85cb3a29ad28cc313",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_proto/archive/97d8af4dc474595af3900dd85cb3a29ad28cc313.tar.gz",
        "https://github.com/bazelbuild/rules_proto/archive/97d8af4dc474595af3900dd85cb3a29ad28cc313.tar.gz",
    ],
)

load(
    "@rules_proto//proto:repositories.bzl",
    "rules_proto_dependencies",
    "rules_proto_toolchains",
)

rules_proto_dependencies()

rules_proto_toolchains()

# ================================================================
# External Swift dependencies. bazel v1.0.0 ✔︎
# ================================================================

aexml_commit = "25d00c973e44d4a5cb6f8ee02e7802db26060259"

git_repository(
    name = "aexml",
    commit = aexml_commit,
    remote = "https://github.com/alex-apriamashvili/AEXML.git"
)

path_kit_commit = "c911eeb18ddacd1b806811823b06f82dbbbb8981"

git_repository(
    name = "path_kit",
    commit = path_kit_commit,
    remote = "https://github.com/alex-apriamashvili/PathKit.git"
)
