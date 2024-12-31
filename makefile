default:
	@zig build run

debug:
	@zig build run -freference-trace

clean:
	@rm -rf ./.zig-cache/