import fs from "fs";
import path from "path";
import { parse, visit } from "@solidity-parser/parser";

const contractsDir = path.join(__dirname, "..", "src");
const outputFile = path.join(__dirname, "..", "generated", "ethos-enums.ts");

interface EnumInfo {
  name: string;
  values: string[];
  contractName?: string;
}

function extractEnums(filePath: string): {
  fileName: string;
  enums: EnumInfo[];
} {
  const content = fs.readFileSync(filePath, "utf8");
  const ast = parse(content);
  const enums: EnumInfo[] = [];
  let currentContract: string | undefined;

  visit(ast, {
    ContractDefinition: (node) => {
      currentContract = node.name;
    },
    EnumDefinition: (node) => {
      enums.push({
        name: node.name,
        values: node.members.map((member) => member.name),
        contractName: currentContract,
      });
    },
  });

  // Deduplicate enums
  const uniqueEnums = enums.filter(
    (enum1, index, self) =>
      index ===
      self.findIndex(
        (enum2) =>
          enum1.name === enum2.name &&
          enum1.contractName === enum2.contractName,
      ),
  );

  return { fileName: path.basename(filePath, ".sol"), enums: uniqueEnums };
}

function generateEnumObject(fileName: string, enumInfo: EnumInfo): string {
  const enumName = enumInfo.contractName
    ? `${enumInfo.contractName}_${enumInfo.name}`
    : enumInfo.name;
  const entries = enumInfo.values
    .map((value, index) => `    ${index}: "${value}",`)
    .join("\n");
  return `export const ${enumName} = {\n${entries}\n} as const;\n\n`;
}

function getAllSolidityFiles(dir: string): string[] {
  let results: string[] = [];
  const list = fs.readdirSync(dir);

  list.forEach((file) => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat && stat.isDirectory()) {
      results = results.concat(getAllSolidityFiles(filePath));
    } else if (path.extname(file) === ".sol") {
      results.push(filePath);
    }
  });

  return results;
}

function generateEnumsFile() {
  let output = "";
  const files = getAllSolidityFiles(contractsDir);

  files.forEach((filePath) => {
    const { enums } = extractEnums(filePath);

    enums.forEach((enumInfo) => {
      output += generateEnumObject(path.basename(filePath, ".sol"), enumInfo);
    });
  });

  fs.mkdirSync(path.dirname(outputFile), { recursive: true });
  fs.writeFileSync(outputFile, output);
  console.log(`Enums generated and saved to ${outputFile}`);
}

generateEnumsFile();
