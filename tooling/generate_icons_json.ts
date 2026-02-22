import fs from "fs";
import { icons } from "@phosphor-icons/core";

const OUTPUT_FILE = "icons_metadata.json";

function log(message: string) {
  console.log(`[generator] ${message}`);
}

log("Starting icon metadata generation...");
log(`Total icons received: ${icons.length}`);

const transformed = icons.map((icon, index) => {
  if (!icon.name || icon.codepoint == null) {
    console.error(
      `[generator][WARN] Invalid icon at index ${index} — missing name or codepoint`
    );
  }

  return {
    name: icon.name,
    pascalName: icon.pascal_name,
    categories: icon.categories ?? [],
    figma_category: icon.figma_category ?? null,
    tags: icon.tags ?? [],
    codepoint: icon.codepoint,
    published_in: icon.published_in ?? null,
    updated_in: icon.updated_in ?? null,
  };
});

log("Transformation completed.");
log("Writing output file...");

fs.writeFileSync(
  OUTPUT_FILE,
  JSON.stringify(transformed, null, 2),
  "utf8"
);

log(`File successfully written to: ${OUTPUT_FILE}`);
log("Generation finished.");