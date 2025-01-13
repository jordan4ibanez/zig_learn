# zig_learn
 
copy memory into buffer:

```zig
// S3D notes:
@memcpy(dest[start_index..], source);
```

```zig
// Freakman and fri3dnstuff note now to copy an array to an array:
myArray[10..20].* = other[0..10].*;
// cloudef notes:
// the reason is that [a..b] is a slicing operator which returns slice and .* deferences it
```

Note: this is written as a conventional OpenGL project. Nothing new here.

Great article on ps1 style graphics
https://www.hawkjames.com/indiedev/update/2022/06/02/rendering-ps1.html

note:
map will be a greyscale texture map.
export gimp as ``16 bpc GRAY`` png.


zig fetch --save git+(github address here)

was researching:
https://github.com/kooparse/zgltf