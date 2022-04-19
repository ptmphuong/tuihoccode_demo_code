% Liệt kê facts về bố/mẹ - con theo format: parent_child(Parent, Child)
parent_child(mrNobi, nobirou).
parent_child(mrsNobi, nobirou).
parent_child(mrNobi, nobisuke).
parent_child(mrsNobi, nobisuke).
parent_child(mrKataoka, tamao).
parent_child(mrsKataoka, tamao).
parent_child(mrKataoka, tamako).
parent_child(mrsKataoka, tamako).
parent_child(nobirou, akiyo).
parent_child(nobisuke, tom).
parent_child(nobisuke, tep).
parent_child(nobisuke, nobita).
parent_child(tamako, tom).
parent_child(tamako, tep).
parent_child(tamako, nobita).


% định nghĩa mối quan hệ Grandparent - Parent - Child
grandparent_grandchild(GrandParent, GrandChild) :-
    parent_child(GrandParent, Parent),
    parent_child(Parent, GrandChild).


% định nghĩa mối quan hệ Grandparent có cùng GrandChild 
mutual_grandchildren(GrandParent1, GrandParent2, GrandChild) :-
    grandparent_grandchild(GrandParent1, GrandChild),
    grandparent_grandchild(GrandParent2, GrandChild).

