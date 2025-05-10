Managing QR Labels for New Production Flow
This scenario occurs when a sales order requires a large quantity of a product, but it is not available in stock. To fulfill the order, we assemble two different products to create the required product.

Example Scenario
We have four products, and two are combined to form a new product:

Product	Before Qty	After Qty
A Cool White Light	40	60
A Warm White Light	40	20
B Cool White Light	40	20
B Warm White Light	40	60
Key Issue:

Before and After Qty labels remain the same, but the product itself changes after assembly.
The current system still shows 40-40 for all products, making it difficult to track the new product allocation.
How to Manage QR Labels in This Flow?
To accurately maintain labels and track product movement, we need to implement a label reassignment process:

1. Create Dynamic QR Labels Based on Assembly
When two products are combined into a new product, generate a new QR label for the finished product.
The new label should store details like:
Original products used (e.g., A Cool White Light + A Warm White Light)
New product ID
Updated storage location
Adjusted quantity
2. Implement a Label Reassignment Rule
The Before Qty label is scanned before assembly.
Once assembly is complete, the system should:
Deduct raw material quantities from storage.
Generate a new QR label for the newly assembled product.
Update the storage location and quantity in the system.
3. Track Movement with Destination Labels
Instead of keeping the same product ID, create a mapping table:
Original Product → New Product
Store the transformation history in the QR label.
Example:
A Cool White Light (Before: 40, After: 60)
B Cool White Light (Before: 40, After: 20)
If these two create a new product, a new QR label should be assigned to track it.
4. Update System to Reflect Correct Qty Movement
Modify the inventory system so that when products are merged:
The old QR label is deactivated or marked as "Used."
A new QR label is assigned to the final product.
The correct product and quantity are displayed in the warehouse stock list.



============================================================================================================
Scenario: Multi-Department Access for Product Management
Currently, our system allows one user to have access to only one department, and both purchase and sales orders are managed based on this single department access. However, in some cases, a single user needs access to multiple departments to manage specific products more efficiently.

Why is Multi-Department Access Needed?
Some products belong to multiple departments based on their usage and storage.
Example:
MCB 1-2 products belong to the Light Department.
Switch & Socket 2-3 products also belong to the Light Department.
These products are stored in the Light Department and their sales orders are also processed accordingly.
User Access Requirement
Pranav Shah needs access to three different departments to effectively manage these products.
If access is restricted to a single department, it becomes difficult to track and manage products that belong to multiple departments.
Proposed Solution
Allow a Single User to Have Multiple Department Access

Modify the system to allow users to be assigned to multiple departments.
This ensures smooth product management across different departments.
Department-Based Product Allocation

Products should be assigned to the correct department based on their storage and sales order processing.
If specific products belong to the Light Department, they should be visible and manageable under this department.
Customization if Required

If the current system does not support multi-department access, we may need to customize the flow to fulfill the user's requirements.