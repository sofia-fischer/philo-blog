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

## ToDo

Git has three stages









