import ArgumentParser
import PPTXKit

@main
struct PPTXAnalyzer: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "pptx-analyzer",
		abstract: "A utility for parsing and analyzing PowerPoint (PPTX) files",
		version: "0.1.0",
		subcommands: [
			Count.self,
			List.self,
			Info.self,
			Summary.self,
			TestImages.self,
			RenderCommand.self
		],
		defaultSubcommand: nil
	)
}