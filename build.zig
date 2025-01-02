const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig_learn",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig_learn",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    //* BEGIN EXTERNAL MODULES. ==========================================================

    // Use mach-glfw
    const glfw_dep = b.dependency("mach-glfw", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));

    // Choose the OpenGL API, version, profile and extensions you want to generate bindings for.
    const gl_bindings = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.6",
        .profile = .core,
        .extensions = &.{ .ARB_clip_control, .NV_scissor_exclusive },
    });
    // Import the generated module.
    exe.root_module.addImport("gl", gl_bindings);

    const zalgebra_dep = b.dependency("zalgebra", .{
        .target = target,
        .optimize = optimize,
    });
    const zalgebra_module = zalgebra_dep.module("zalgebra");
    exe.root_module.addImport("zalgebra", zalgebra_module);

    //* BEGIN INTERNAL MODULES. ==========================================================

    // I call this style: dumpEverythingIntoAModule5000

    const Searcher = struct {
        fn search(dirString: []const u8, allocator: std.mem.Allocator, moduleMap: *std.hash_map.StringHashMap([]const u8)) void {
            // std.debug.print("hi {s}\n", .{dir});

            var dir = std.fs.cwd().openDir(dirString, .{ .iterate = true }) catch |err| {
                std.log.err("{}", .{err});
                std.process.exit(1);
            };

            var iter = dir.iterate();
            while (iter.next() catch |err| {
                std.log.err("{}", .{err});
                std.process.exit(1);
            }) |file| {
                if (file.kind == .directory) {
                    const newDirString = std.fmt.allocPrint(allocator, "{s}/{s}", .{ dirString, file.name }) catch |err| {
                        std.log.err("{}", .{err});
                        std.process.exit(1);
                    };
                    defer allocator.free(newDirString);

                    // std.debug.print("folder: {s}\n", .{newDirString});
                    search(newDirString, allocator, moduleMap);
                }

                // This could maybe search for an ignore.txt for specific folders or something.

                if (file.kind == .file) {
                    const newDirString = std.fmt.allocPrint(allocator, "{s}/{s}", .{ dirString, file.name }) catch |err| {
                        std.log.err("{}", .{err});
                        std.process.exit(1);
                    };
                    // defer allocator.free(newDirString);

                    // Ignore anything but zig files.
                    if (std.mem.eql(u8, file.name[file.name.len - 4 ..], "zig")) {
                        continue;
                    }

                    // This could have more things added in. :)
                    if (std.mem.eql(u8, file.name, "main.zig") or std.mem.eql(u8, file.name, "root.zig")) {
                        // std.debug.print("nope, {s}\n", .{file.name});
                        continue;
                    }

                    // If you don't want the full path, you can change the module name to:
                    // file.name.len - 4 and memcpy it the same way.

                    const moduleName = allocator.alloc(u8, newDirString.len - 8) catch |err| {
                        std.log.err("{}", .{err});
                        std.process.exit(1);
                    };

                    @memcpy(moduleName, newDirString[4 .. newDirString.len - 4]);

                    moduleMap.put(moduleName, newDirString) catch |err| {
                        std.log.err("{}", .{err});
                        std.process.exit(1);
                    };

                    // std.debug.print("file: {s}\n", .{file.name[file.name.len - 4 ..]});
                    // std.debug.print("module name: {s}\n", .{moduleName});
                    // std.debug.print("file: {s}\n", .{newDirString});
                }

                // try files.append(b.dupe(file.name));
            }
        }
    };

    var moduleMap = std.StringHashMap([]const u8).init(b.allocator);

    Searcher.search("src", b.allocator, &moduleMap);

    var iter = moduleMap.iterator();

    while (iter.next()) |entry| {
        const moduleName = entry.key_ptr.*;
        // defer b.allocator.free(entry.key_ptr.*);
        const modulePath = entry.value_ptr.*;
        // defer b.allocator.free(entry.value_ptr.*);

        // std.debug.print("Module: [{s}] added | [{s}]\n", .{ moduleName, modulePath });

        // const blah: *std.Build.Module = exe.root_module.import_table.get("k") orelse {
        //     std.process.exit(1);
        // };

        const mod = b.createModule(.{
            .root_source_file = b.path(modulePath),
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        });

        // A smol price to pay, you have to duplicate add in modules from the main scope.
        mod.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
        mod.addImport("gl", gl_bindings);
        mod.addImport("zalgebra", zalgebra_module);

        exe.root_module.addImport(moduleName, mod);
    }

    moduleMap.clearAndFree();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
