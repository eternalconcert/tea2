#include <set>
#include <string>
#include "ast.h"
#include "../exceptions.h"

ImportNode::ImportNode(char *importPath, AstNode *scope, std::string baseDir) {
    this->importPath = importPath;
    this->baseDir = baseDir;
    this->scope = scope;
    AstNode();
};

static void collectExportedNames(AstNode *moduleScope, std::set<std::string> *exportedNames) {
    AstNode *cur = moduleScope->childListHead;
    while (cur != NULL) {
        if (cur->exported) {
            FnDeclarationNode *fn = dynamic_cast<FnDeclarationNode*>(cur);
            if (fn != NULL) {
                exportedNames->insert(fn->identifier);
            }

            VarNode *var = dynamic_cast<VarNode*>(cur);
            if (var != NULL) {
                exportedNames->insert(var->identifier);
            }

            VarDeclarationNode *declaration = dynamic_cast<VarDeclarationNode*>(cur);
            if (declaration != NULL) {
                exportedNames->insert(declaration->identifier);
            }
        }
        cur = cur->getNext();
    }
}

AstNode* ImportNode::evaluate() {
    std::string resolvedPath = resolveTeaPath(this->importPath, this->baseDir);

    if (isTeaModuleImported(resolvedPath)) {
        copyImportedTeaModuleValues(resolvedPath, this->scope);
        return this->getNext();
    }

    if (!beginTeaModuleImport(resolvedPath)) {
        throw SystemError("Import cycle detected: " + resolvedPath);
    }

    AstNode *moduleScope = new AstNode();
    moduleScope->parent = this->scope;

    parseTeaFileIntoScope(resolvedPath, moduleScope);

    std::set<std::string> exportedNames;
    collectExportedNames(moduleScope, &exportedNames);

    moduleScope->evaluate();

    for (auto const& item : moduleScope->valueStore->values) {
        if (exportedNames.count(item.first) > 0) {
            this->scope->valueStore->set(item.first, item.second);
            registerImportedTeaModuleValue(resolvedPath, item.first, item.second);
        }
    }

    finishTeaModuleImport(resolvedPath);
    return this->getNext();
};
