[TOC]

# DesignPatterns

设计模式思想最早应用于建筑，它描述了应用中不断重复的应用发生的问题，以及该问题的解决方案的核心。

经验对于一个设计者很重要，它能够解避免一些问题，是实践中不断积累。然而对于新手，通常无从下手，而内行的设计者知道，不需要任何事情都从头做起，他们更愿意使用以前使用过的解决方案。设计模式即是将这些良好的设计经验记录下来，新手就能够在已有的良好设计的经验下开发，而不是从头实践。



## 面向对象设计的五个基本原则（SOLID）

将其放在设计模式里，不一定合适，但是也应该是可控参考衡量的标准。毕竟都是应用于面向对象设计的场景。既然是基本原则，那设计模式也应该符合这些基本原则。


> 1. 单一职责原则（Single Responsibility Principle, SRP）

一个类包含单一的职责。

- 一个类包含太作的职责会让代码臃肿，而且，功能之间的组合使用变得困难。

- 多个职责在一各类中，很容易形成依赖。如果修改某个职责，很容易引起其他职责发生错误。


> 2. 开放封闭原则(Open - ClosedPrinciple ,OCP)

定义：一个模块、类、函数应当是对修改关闭，扩展开放。

- 修改原有的代码可能会导致原本正常的功能出现问题。

- 因此，当需求有变化时，最好是通过扩展来实现，增加新的方法满足需求，而不是去修改原有代码。


> 3. 里氏代换原则( Liskov Substitution Principle ,LSP )

定义：使用父类的地方能够使用子类来替换，反过来，则不行。


> 4.依赖倒转原则( Dependence Inversion Principle ,DIP )

定义：抽象不应该依赖于细节，细节应当依赖于抽象。

- 即要面向接口编程，而不是面向具体实现去编程。

> 5. 接口隔离法则(Interface Segregation Principle，ISL）

定义：一个类对另一个类的依赖应该建立在最小的接口上。

- 一个类不应该依赖他不需要的接口。
- 接口的粒度要尽可能小，如果一个接口的方法过多，可以拆成多个接口。

> 6.迪米特法则(Law of Demeter, LoD)

定义：一个类尽量不要与其他类发生关系

- 一个类对其他类知道的越少，耦合越小。
- 当修改一个类时，其他类的影响就越小，发生错误的可能性就越小。


## Type


There are 23 Design Pattrens and they can devide into 3 types by the goal of used:

- Creational(5)
- Structural(7)
- Behaioral(11)

Or by the range of used they can devider into:

- Class Pattern: 
- Object Pattern

## Types

<table>
    <thead>
        <tr>
            <th colspan="2"></th><th colspan='3'>Goal</th>
        </tr>
        <tr>
            <th colspan="2"></th><th>Creational</th><th>Structural</th><th>Behaioral</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan='2'>Range</td>
            <td>Class</td>
            <td>Factory Method</td>
            <td>Adapter</td>
            <td>
                Interpreter</br>
                Template Method
            </td>
        </tr>
        <tr>
            <td>Object</td>
            <td>
                Abstract Factory</br>
                Builder</br>
                Prototype</br>
                Singleton
            </td>
            <td>
                Adapter</br>
                Bridge</br>
                Composite</br>
                Decorator</br>
                Facade</br>
                Flyweight</br>
                Proxy
            </td>
            <td>
                Chain of Responsibility</br>
                Command</br>
                Iterator</br>
                Mediator</br>
                Memento</br>
                Observer</br>
                State</br>
                Stragegy</br>
                Visitor
            </td>
        </tr>
    </tbody>
</table>


## Use range of Design Pattern


<table>
    <thead>
        <tr>
            <th>Goal</th><th>Design Patterm</th><th>Change site</th>
        </tr>
    </thead>
    <tbody>
        <tr style="border-top-style:inset;border-top:thick signle #ff0000;">
            <td rowspan='5'>Creational</td>
            <td><a href='create/abstract-factory.md'>Abstract Factory</a></td>
            <td>The families of productor.</td>
        </tr>
        <tr>
            <td><a href='create/builder.md'>Builder</a></td>
            <td>How to create a combination object.</td>
        </tr>
        <tr>
            <td><a href='create/factory_method.md'>Factory Method</a></td>
            <td>Create subclass object.</td>
        </tr>
        <tr>
            <td><a href="create/prototype.md">Prototype</a></td>
            <td>Create object.</td>
        </tr>
        <tr>
            <td><a href='create/singleton.md'>Singleton</a></td>
            <td>Only one instance of a class.</td>
        </tr>
        <tr style="border-top-style:inset;border-top:thick signle #ff0000;">
            <td rowspan='7'>Structural</td>
            <td><a href='structural_patterns/adapter.md'>Adapter</a></td>
            <td>Interface between class or object</td>
        </tr>
        <tr>
            <td><a href='structural_patterns/bridge.md'>Bridge</a></td>
            <td>Implement of object</td>
        </tr>
        <tr>
            <td><a href='structural_patterns/composite.md'>Composite</a></td>
            <td>The structure and compose of an object</td>
        </tr>
        <tr>
            <td>Decorator</td>
            <td>The responsibility of an object, not generate subclass</td>
        </tr>
        <tr>
            <td>Facade</td>
            <td>The interface of a subsyctem</td>
        </tr>
        <tr>
            <td>Flyweight</td>
            <td>Object storage overhead</td>
        </tr>
        <tr>
            <td>Proxy</td>
            <td>How to access an object; The space of that object.</td>
        </tr>
        <tr style="border-top-style:inset;border-top:thick signle #ff0000;">
            <td rowspan='11'>Behaioral</td>
            <td>Chain of Responsibility</td>
            <td>Satisfy the object's request</td>
        </tr>
        <tr>
            <td>Command</td>
            <td>When and How to satisfy the request.</td>
        </tr>
        <tr>
            <td>Interpreter</td>
            <td>The grammar and interpretation of a language</td>
        </tr>
        <tr>
            <td>Iterator</td>
            <td>How to iterator ot access the item of a site.</td>
        </tr>
        <tr>
            <td>Mediator</td>
            <td>How and Who to communicate between objects.</td>
        </tr>
        <tr>
            <td>Memento</td>
            <td>Which private message storage outside of this object, when to storage it.</td>
        </tr>
        <tr>
            <td>Observer</td>
            <td>Multi object dependece another objecrt, and how to keep those object same.</td>
        </tr>
        <tr>
            <td>State</td>
            <td>The state of object</td>
        </tr>
        <tr>
            <td>Stragegy</td>
            <td>Algorithm</td>
        </tr>
        <tr>
            <td>Template Method</td>
            <td>Some step of the Algorithm</td>
        </tr>
        <tr>
            <td>Visitor</td>
            <td>Some operator can used to a (group) object, but not change the class of those object.</td>
        </tr>
    </tbody>
</table>


## 从哪些维度评判代码质量的好坏

可维护性

可读

可扩展性




