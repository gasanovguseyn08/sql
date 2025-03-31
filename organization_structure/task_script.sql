---------------------------1------------------------------------
SELECT 
    e.EmployeeID,
    e.Name,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (SELECT GROUP_CONCAT(DISTINCT p.ProjectName SEPARATOR ', ') 
     FROM Projects p 
     WHERE p.DepartmentID = e.DepartmentID) AS Projects,
    (SELECT GROUP_CONCAT(DISTINCT t.TaskName SEPARATOR ', ') 
     FROM Tasks t 
     WHERE t.AssignedTo = e.EmployeeID) AS Tasks
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON e.RoleID = r.RoleID
WHERE e.ManagerID IN (
    SELECT EmployeeID FROM Employees WHERE ManagerID = 1
    UNION
    SELECT EmployeeID FROM Employees WHERE ManagerID IN (
        SELECT EmployeeID FROM Employees WHERE ManagerID = 1
    )
)
ORDER BY e.Name;
---------------------------2------------------------------------
SELECT 
    e.EmployeeID,
    e.Name,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (SELECT GROUP_CONCAT(DISTINCT p.ProjectName SEPARATOR ', ') 
     FROM Projects p 
     WHERE p.DepartmentID = e.DepartmentID) AS Projects,
    (SELECT GROUP_CONCAT(DISTINCT t.TaskName SEPARATOR ', ') 
     FROM Tasks t 
     WHERE t.AssignedTo = e.EmployeeID) AS Tasks,
    (SELECT COUNT(*) FROM Tasks t WHERE t.AssignedTo = e.EmployeeID) AS TaskCount,
    (SELECT COUNT(*) FROM Employees sub WHERE sub.ManagerID = e.EmployeeID) AS SubordinateCount
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON e.RoleID = r.RoleID
WHERE e.ManagerID IN (
    SELECT EmployeeID FROM Employees WHERE ManagerID = 1
    UNION
    SELECT EmployeeID FROM Employees WHERE ManagerID IN (
        SELECT EmployeeID FROM Employees WHERE ManagerID = 1
    )
)
ORDER BY e.Name;
---------------------------3------------------------------------
SELECT 
    e.EmployeeID,
    e.Name,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (SELECT GROUP_CONCAT(DISTINCT p.ProjectName SEPARATOR ', ') 
     FROM Projects p 
     WHERE p.DepartmentID = e.DepartmentID) AS Projects,
    (SELECT GROUP_CONCAT(DISTINCT t.TaskName SEPARATOR ', ') 
     FROM Tasks t 
     WHERE t.AssignedTo = e.EmployeeID) AS Tasks,
    (SELECT COUNT(*) FROM Employees sub WHERE sub.ManagerID = e.EmployeeID) AS SubordinateCount
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON e.RoleID = r.RoleID
WHERE r.RoleName LIKE 'Менеджер'
AND (SELECT COUNT(*) FROM Employees sub WHERE sub.ManagerID = e.EmployeeID) > 0
ORDER BY e.Name;

