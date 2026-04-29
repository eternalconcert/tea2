#include "ast.h"
#include "../commons.h"

void teaResetBreakContinueFlags(AstNode *n) {
    if (n == NULL) {
        return;
    }
    if (n->statementType == BREAK || n->statementType == CONTINUE) {
        n->statementType = OTHER;
    }

    if (dynamic_cast<WhileNode*>(n) != nullptr) {
        WhileNode *w = (WhileNode*)n;
        teaResetBreakContinueFlags(w->condition);
        teaResetBreakContinueFlags(w->childListHead);
        return;
    }

    if (dynamic_cast<ForNode*>(n) != nullptr) {
        ForNode *f = (ForNode*)n;
        teaResetBreakContinueFlags(f->init);
        teaResetBreakContinueFlags(f->condition);
        teaResetBreakContinueFlags(f->post);
        teaResetBreakContinueFlags(f->childListHead);
        return;
    }

    if (dynamic_cast<IfNode*>(n) != nullptr) {
        IfNode *iff = (IfNode*)n;
        for (AstNode *c = iff->childListHead; c != NULL; c = c->getNext()) {
            teaResetBreakContinueFlags(c);
        }
        teaResetBreakContinueFlags(iff->elseBlock);
        return;
    }

    for (AstNode *c = n->childListHead; c != NULL; c = c->getNext()) {
        teaResetBreakContinueFlags(c);
    }
}

TeaBCKind teaFindBreakContinue(AstNode *n) {
    if (n == NULL) {
        return TEA_BC_NONE;
    }
    if (n->statementType == BREAK) {
        return TEA_BC_BREAK;
    }
    if (n->statementType == CONTINUE) {
        return TEA_BC_CONTINUE;
    }

    if (dynamic_cast<WhileNode*>(n) != nullptr) {
        WhileNode *w = (WhileNode*)n;
        TeaBCKind k = teaFindBreakContinue(w->condition);
        if (k != TEA_BC_NONE) {
            return k;
        }
        return teaFindBreakContinue(w->childListHead);
    }

    if (dynamic_cast<ForNode*>(n) != nullptr) {
        ForNode *f = (ForNode*)n;
        TeaBCKind k = teaFindBreakContinue(f->init);
        if (k != TEA_BC_NONE) {
            return k;
        }
        k = teaFindBreakContinue(f->condition);
        if (k != TEA_BC_NONE) {
            return k;
        }
        k = teaFindBreakContinue(f->post);
        if (k != TEA_BC_NONE) {
            return k;
        }
        return teaFindBreakContinue(f->childListHead);
    }

    if (dynamic_cast<IfNode*>(n) != nullptr) {
        IfNode *iff = (IfNode*)n;
        for (AstNode *c = iff->childListHead; c != NULL; c = c->getNext()) {
            TeaBCKind k = teaFindBreakContinue(c);
            if (k != TEA_BC_NONE) {
                return k;
            }
        }
        return teaFindBreakContinue(iff->elseBlock);
    }

    for (AstNode *c = n->childListHead; c != NULL; c = c->getNext()) {
        TeaBCKind k = teaFindBreakContinue(c);
        if (k != TEA_BC_NONE) {
            return k;
        }
    }
    return TEA_BC_NONE;
}

BreakNode::BreakNode() {
    AstNode();
}

AstNode* BreakNode::evaluate() {
    this->statementType = BREAK;
    return NULL;
}

ContinueNode::ContinueNode() {
    AstNode();
}

AstNode* ContinueNode::evaluate() {
    this->statementType = CONTINUE;
    return NULL;
}

AstNode* WhileNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->condition;
    condition->evaluate();

    while (condition->value->boolValue) {
        if (this->childListHead != NULL) {
            teaResetBreakContinueFlags(this->childListHead);
            this->childListHead->evaluate();
            if (teaFindReturnExecuted(this->childListHead) != nullptr) {
                break;
            }
            TeaBCKind bc = teaFindBreakContinue(this->childListHead);
            teaResetBreakContinueFlags(this->childListHead);
            if (bc == TEA_BC_BREAK) {
                break;
            }
            if (bc == TEA_BC_CONTINUE) {
                condition->evaluate();
                continue;
            }
        }
        condition->evaluate();
    }

    return this->getNext();
}

AstNode* ForNode::evaluate() {
    if (this->init != NULL) {
        this->init->evaluate();
    }

    ExpressionNode *condition = (ExpressionNode*)this->condition;
    bool hasCondition = (condition != NULL);
    if (hasCondition) {
        condition->evaluate();
    }

    while (!hasCondition || condition->value->boolValue) {
        if (this->childListHead != NULL) {
            teaResetBreakContinueFlags(this->childListHead);
            this->childListHead->evaluate();
            if (teaFindReturnExecuted(this->childListHead) != nullptr) {
                break;
            }
            TeaBCKind bc = teaFindBreakContinue(this->childListHead);
            teaResetBreakContinueFlags(this->childListHead);
            if (bc == TEA_BC_BREAK) {
                break;
            }
        }

        if (this->post != NULL) {
            this->post->evaluate();
        }

        if (hasCondition) {
            condition->evaluate();
        }
    }

    return this->getNext();
}
