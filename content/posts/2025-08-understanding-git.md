---
title: "Leveling Up Git Skills"

date: 2025-07-10T10:20:44+02:00

draft: false

description: Learning more about git

tags: [ "Development" ]
---

{{< lead >}}

{{< /lead >}}

## Git Step by Step from File to Commit

Working with Git is a common task for developers. Different projects have different expectations on git should be used.
In the last months I had to upgrade my git skills and wanted to share some of the things I learned.

‼️ This post about what I learned additionally, therefore some basic git knowledge is assumed. 

### Hashes as Object IDs

Git uses a lot of hashes of files referred to as Object IDs (OID).
Hash the content of the file. This hashing creates a unique (40 char) identifier for the content (using SHA-1). For two
files with the same content, the hash will be the same, the file name or location does not matter.
Adding two files with the same content will result in the same hash being created.

```shell
> cat README.md | git hash-object --stdin
0588748a531675ba06e473ae4d74532cdb2f94d3
```

## Blob is one Git Object

Git will create a blob in the `.git` directory with the hash as name and the zipped content of the file as content.
Git is a Content addressable file system, which means that the content of the file is used to determine the file
location.

```text
.git/objects
├── 05
│   └── 88748a531675ba06e473ae4d74532cdb2f94d3
|       "Blob of the file content (zipped)"
├── info
└── pack
```

If multiple filed are added, one blob is created for each file. Two files with the same content will be added as one
blob. Editing a file will create a new blob with a new hash, the old blob will still be there. Without a commit, this
blob is not reachable, git only keeps history of committed files.
**Git is Immutable** - a blob cannot be changed, only new blobs can be created. The git garbage collector will remove
the blobs that are not referenced by any link eventually.

Git is not copying the files. Unchanged files are not copied, only the tree object is created with the hash of the blob
of the unchanged file pointing to one content.

### A Tree is a Git Object

To store the relation of the file name and the blob, git creates a tree object. A Tree object is a file that contains a
list in which the file type, file name, and the Hash Object ID. The Tree file hashed will again be the Object ID for the
tree, therefore it will also be the same if all file contents and the file names in the tree are the same.

```shell
> git write-tree
2d66c1b551aae5efa0d242cc105b8531d3ae5e4b
> git cat-file -p 2d66c1b551aae5efa0d242cc105b8531d3ae5e4b
040000 tree 9b6bc3d88d357e1f02cda9e279f0bc9a9c5c11a3	content
040000 tree b8e6c8eb08befc5a0fde3b0c2821c806c7be2b36	public
100644 blob 0588748a531675ba06e473ae4d74532cdb2f94d3	readme.md
100644 blob 0588748a531675ba06e473ae4d74532cdb2f94d3	readme_copy.md
040000 tree bac8dc35897c3fe58c6f3d321deea5ee7dfff50f	resources
```

`git write-tree` creates a tree object from the staged files, this is usually done automatically when committing.
In the tree file, different files with the same content will point to the same hash (blob).
The output shows the tree object with the following structure:

```text
100644 blob 0588748a531675ba06e473ae4d74532cdb2f94d3	readme.md
100644     -> Git file Type (binary 1000 (regular file), 1010 (symbolic link) and 1110 (gitlink) 
              and Linux file mode, binary authorization (0644/-rw-r--r--)
blob       -> The type of the object, in this case a blob. Subdirectories (like public) 
              are modeled as trees. 
0588748a...-> The OID (Object ID), Hash of the blob
readme.md  -> The name of the file
```

While staged the tree objects are also added to the `.git/objects.` directory.

```text
.git/objects
├── 2d   # The root tree object
│   └── 66c1b551aae5efa0d242cc105b8531d3ae5e4b 
├── 9b   # The tree object for the content directory
│   └── 6bc3d88d357e1f02cda9e279f0bc9a9c5c11a3 
├── b8   # The tree object for the public directory
│   └── e6c8eb08befc5a0fde3b0c2821c806c7be2b36
├── 05   # The blob object for the readme.md file
│   └── 88748a531675ba06e473ae4d74532cdb2f94d3
...
├── info
└── pack
```

### A Commit is a Git Object

Git creates a commit object, which again is a file containing the hash of a tree object, the hash of the parent commit,
an author and committer, and the commit message. The commit object also has a hash stored in the `.git/objects`
directory.

```shell
❯ git cat-file -p 46cbcbdd595811bb59cbbc307d061dfaa7478a85
  tree 6a58a71284938e520f1c21f24971dbe14821fbd7
  parent 45dda006756054c4fd77fd9a0423a7033f21dbfd
  author Sofia Fischer <sofia@philodev.com> 1752449645 +0200
  committer Sofia Fischer <sofia@philodev.com> 1752449645 +0200
  
  ✨ Post about bitemporal data
```

{{< alert "circle-info" >}} **Git allways commits the whole tree**:
Every git commit contains the whole tree, not just the changes.
This means git can allways provide the repository in one point in time without calculating any stacking diffs.   
This behavior is the what did set git apart from other versin control systems in the past (although now alternatives
with this behavior exist)
{{< /alert >}}

## Branches, Heads, Tags

### Branches

A Branch is a named reference to a commit. The branches are stored in the `.git/refs/heads` directory.

```shell
❯ ls .git/refs/heads
master  bitemporal

❯ cat .git/refs/heads/master
96b73cbfd9cb66356737ce3282986c2f8aa225b1
```

Deleting a branch will only delete the file with the reference to one commit. If the commit is not fully merged, this
might delete the only reference to the commit making the commit "orphaned" and unreachable.

### Head

The head is a reference to the current branch. The head is stored in `.git/HEAD` and contains the name of the current
The head references the commit that will be the parent of the next commit.

```shell
❯ cat .git/HEAD
ref: refs/heads/main
```

Head may also point to a commit directly, this is called a "detached head". What sounds spooky, is actually a nice way
to travel back in time and look at the state of the repository at a specific commit. The reason why "detached head"
causes panic is that the next commit will not be on a branch, and will be orphaned if head is changed. It is a feature
of branches that they change on commit to point to the latest commit on the branch. So the solution is to just switch
back to a branch.

One way to "save" a commit in a detached head state is to add a tag to the commit. Tags are references to a specific
commit. Now when head is changed, the commit will not be orphaned, as the tag will still point to the commit.

## Making pretty Git Commits in Practice

While the git commits of some developers look like the developer had a plan for their feature, which unfolded
flawlessly - one commit contained refactoring to make the change easy, one commit added unreachable new code with tests,
and one connected it in multiple places. The dream of every reviewer is most commonly not the result of a developer who
planned all actions upfront in perfection, but rather the result of using git to create readable, easy to review
commits.

## Commiting some lines of a file

Many of the features I can implement start out as a single commit, but then I realise some refactoring that should go in
a separate commit.
Git allows to stage only parts of a file with `git add -p` or `git add --patch`. This will show the changes in the file
and allow you to select a subset of the changes to stage. For each patch of code git will ask you if you want to stage
it:

* `y` - yes, stage this hunk
* `n` - no, do not stage this hunk
* `a` - stage this and all the remaining hunks in the file
* `d` - do not stage this hunk nor any of the remaining hunks in the file
* `g` - go to the selected hunk
* `/` - search for a hunk matching the given regex
* `j` - leave this hunk undecided, see next undecided hunk
* `J` - leave this hunk undecided, see next hunk
* `k` - leave this hunk undecided, see previous undecided hunk
* `K` - leave this hunk undecided, see previous hunk
* `s` - split the current hunk into smaller hunks
* `e` - edit the current hunk manually
* `?` - print help”

In PyCharm (or Intellij) you can also stage parts of a file by selecting the lines you want to stage in the preview of
the commit dialog.

## Change something in a commited commit

It is also possible to change something in a past commit to ensure a clean commit history. The easiest way to do this is
using `git commit --amend`. This will take the current staged changes and add them to the last commit. This is only
possible if the commit to change is the last commit.

If the commit is not further down the commit history, git allows to change a past commit by adding a new commit with the
message `fixup! <commit message>`. As an easier way to do this, you can use `git commit --fixup <commit hash>`, in the
GUI of PyCharm by right clicking on the commit to change and selecting "Fixup commit".

As an example, to fix some spelling mistakes in a blog post `✨add post about bitemporal data` after I changed the some
internal things for my blog, I could end up with the following commits:

```shell
d01fd6 fixup! ✨add post about bitemporal data
c028f4 🚀 use go modules instead of git submodules
b032c2 ✨add post about bitemporal data
```

The fixup commit will be squashed into the `b032c2` commit on interactive rebase or on merge if used with
`--autosquash`.

## Interactive Rebase

Interactive rebase is a powerful tool to change the commit history. It allows you to reorder, squash, or edit commits.



## ToDo

Git has three stages









