#include <map>
#include "exceptions.h"


int intAddInt(int lval, int rval) {
    return lval + rval;
};

std::string strAddStr(std::string lval, std::string rval) {
    return lval + rval;
};


class ValueStore {
    public:
        char *rawValue;

};

std::map <std::string, ValueStore> values;


enum nodeTypeId {ROOT, INT, FLOAT, STR, DECLARATION, ADD, SUB, MUL, DIV, IDENTIFIER, TYPE};


nodeTypeId getNodeTypeByName(char *name) {
        if (!strcmp(name, "+")) {
            return ADD;
        }
        if (!strcmp(name, "-")) {
            return SUB;
            }
        if (!strcmp(name, "*")) {
            return MUL;
        }
        if (!strcmp(name, "/")) {
            return DIV;
    }
}

int maxId = 0;


class AstNode {
public:
    AstNode *childListHead = NULL;
    AstNode *next = NULL;
    AstNode *parent = NULL;
    nodeTypeId nodeType;
    int id;
    char *value;

    AstNode(nodeTypeId nodeType) {
        this->id = maxId;
        this->nodeType = nodeType;
        maxId++;
    }

    void addToChildList(AstNode *newNode) {
        newNode->parent = this;
        if (childListHead == NULL) {
            childListHead = newNode;
        }
        else {
            AstNode *current = childListHead;
            while (current->next != NULL) {
                current = current->next;
            }
            current->next = newNode;
        }
    };

    void execute() {
        if (this->nodeType == ADD) {
            if (this->childListHead->nodeType == INT and this->childListHead->next->nodeType == INT) {
                int lval = atoi(this->childListHead->value);
                int rval = atoi(this->childListHead->next->value);
                printf("%i\n", intAddInt(lval, rval));
            }
            else if (this->childListHead->nodeType == STR and this->childListHead->next->nodeType == STR) {
                printf("%s\n", "GOGOG");
                int lval = atoi(this->childListHead->value);
                int rval = atoi(this->childListHead->next->value);
                printf("%i---------\n", intAddInt(lval, rval));
            }

        }

        if (this->nodeType == SUB) {
            int lval = atoi(this->childListHead->value);
            int rval = atoi(this->childListHead->next->value);
            printf("%i\n", lval - rval);
        }

        if (this->nodeType == MUL) {
            int lval = atoi(this->childListHead->value);
            int rval = atoi(this->childListHead->next->value);
            printf("%i\n", lval * rval);
        }

        if (this->nodeType == DIV) {
            int lval = atoi(this->childListHead->value);
            int rval = atoi(this->childListHead->next->value);
            printf("%i\n", lval / rval);
        }

        if (this->nodeType == DECLARATION) {
            printf("Assigned the value %s to the identifier %s of type %s\n", this->childListHead->next->next->value, this->childListHead->next->value, this->childListHead->value);
            ValueStore newValue = ValueStore();
            newValue.rawValue = this->childListHead->next->next->value;
            values[std::string(this->childListHead->next->value)] = newValue;
        }
    }
};


AstNode *rootNode = new AstNode(ROOT);
AstNode *currentHeadNode = rootNode;

AstNode *curNode = currentHeadNode;

void runNodes(AstNode *curNode) {
    if (curNode == NULL) {
        return;
    }

    else{
        curNode->execute();

        if (curNode->next != NULL) {
            runNodes(curNode->next);
        }
        else {
            runNodes(curNode->childListHead);
        }
    }
}

void runProgram() {
    runNodes(curNode);
    printf("%s\n", values["a"].rawValue);
}







// Helpers

void declareLit(char *typeValue, char *identValue, char *rValValue, const char *typeName) {
    if (strcmp(typeValue, typeName)) {
        throw ParserError("Type error in literal assignment: " + std::string(typeValue) + " " + std::string(identValue) + " != " + std::string(typeName));
    }

    AstNode *decl = new AstNode(DECLARATION);
    currentHeadNode->addToChildList(decl);

    AstNode *type = new AstNode(TYPE);
    type->value = typeValue;
    decl->addToChildList(type);

    AstNode *ident = new AstNode(IDENTIFIER);
    ident->value = identValue;
    decl->addToChildList(ident);

    AstNode *rVal = new AstNode(INT);
    rVal->value = rValValue;
    decl->addToChildList(rVal);
}
