#include <string.h>
#include "ast.h"


AstNode* IfNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->childListHead;
    condition->evaluate();
    if (condition->value->boolValue) {
        AstNode *thenBlk = this->childListHead->getNext();
        teaResetBreakContinueFlags(thenBlk);
        thenBlk->evaluate();
        TeaBCKind bc = teaFindBreakContinue(thenBlk);
        if (bc == TEA_BC_BREAK || bc == TEA_BC_CONTINUE) {
            return NULL;
        }
    }
    else if (this->elseBlock != NULL) {
        teaResetBreakContinueFlags(this->elseBlock);
        this->elseBlock->evaluate();
        TeaBCKind bc = teaFindBreakContinue(this->elseBlock);
        if (bc == TEA_BC_BREAK || bc == TEA_BC_CONTINUE) {
            return NULL;
        }
    }
    return this->getNext();
};
